require "yaml"
require "net/http"
require "json"

module UlakTest
  module Hooks
    class IssueAssociatedRevision < Redmine::Hook::ViewListener
      def view_issues_show_details_bottom(context = {})
        Rails.logger.info(">>> IssueAssociatedRevision.view_issues_show_details_bottom <<<<")
        issue = context[:issue]
        associated_revisions = findTagsOfCommits(issue)

        # deb Paketlerini yükleyebileceğimiz sunucuların listesini çekiyoruz
        servers = JenkinsScriptlerApiController.get_environments_by_arch("VNF")

        jenkins_url = "https://jenkins-5gcn.ulakhaberlesme.com.tr"
        job = "view/DevOps/job/DevOps/job/5GCN-Deployment"
        job_token = "5gcn_deploy"

        hook_caller = context[:hook_caller]
        controller = hook_caller.is_a?(ActionController::Base) ? hook_caller : hook_caller.controller

        output = controller.send(:render_to_string, {
          partial: "issues/tabs/issue_associated_revision",
          locals: {
            "@changesets": issue.changesets,
            artifacts: associated_revisions,
            servers: servers,
            jenkins: {
              url: jenkins_url,
              job: job,
              job_token: job_token,
            },
          },
        })

        output
      end

      def findTagsOfCommits(issue)
        associated_revisions = []
        issue.changesets&.each do |cs|
          # Çalıştırılacak komutu hazırlayın
          # git_tag_command = "git -C #{Repository.find_by_id(cs.repository_id).url} tag --contains #{cs.revision}"
          isMergeTags = false
          merge_tags = isMergeTags ? "--merged" : ""
          git_tag_command = "git -C #{cs.repository.url} tag #{merge_tags} --contains #{cs.revision} "
          puts ">>>> git_tag_command: #{git_tag_command}"

          # Komutu çalıştırın ve çıktıyı yakalayın
          git_tags_output = `#{git_tag_command}`

          # Etiketleri alın
          tags = git_tags_output.split("\n")

          # Her etiket için açıklamayı alın ve eşleşen etiketleri yazdırın
          tags.each do |tag|
            # Etiket açıklamasını almak için `git show` komutunu kullanın
            # git_show_command = "git -C #{Repository.find_by_id(cs.repository_id).url} show #{tag}"
            # git_show_command = "git -C #{cs.repository.url} show #{tag}"
            git_cat_command = "git -C #{cs.repository.url} cat-file -p #{tag}"
            puts ">>>> git_cat_command: #{git_cat_command}"
            git_cat_output = `#{git_cat_command}`

            # Eğer etiket varsa açıklamayı alın, yoksa "No description" yazın
            description = git_cat_output.empty? ? "No description" : git_cat_output

            begin
              # İlk boş satırdan sonraki kısmı alıyoruz
              # puts ">>>> description: #{description}"
              yaml_part = description.lines.drop_while { |line| line.strip != "" }.join

              # YAML'i Ruby nesnesine çeviriyoruz
              ruby_object = YAML.safe_load(yaml_part)

              # Ruby nesnesini kullanabiliriz
              if ruby_object["distros"].present?
                # Artifacts hashini oluşturup revisions listesine ekleyin
                artifacts = ruby_object
                associated_revisions << { changeset_id: cs, artifacts: artifacts }
              end
            rescue Psych::SyntaxError => e
              # Eğer YAML formatında bir hata varsa burada işleyebiliriz
              puts "<<<<<< YAML formatında hata: #{e.message}"
            end
          end # < tags.each
        end # < issue.changesets&.each
        associated_revisions
      end

      def self.generate_jenkins_job_url(debian_package, target_server)
        # Jenkins JOB URL
        parameters = "DEBIAN_PACKAGE=#{debian_package}&openStackName=#{target_server}"
        jenkins_job_url = "#{@JENKINS_URL}/#{@JOB}/buildWithParameters?token=#{@JOB_TOKEN}&#{parameters}"
        jenkins_job_url
      end

      def self.format_artifacts_table(artifacts)
        formatted_artifacts = YAML.dump(artifacts).gsub(/registry\.ulakhaberlesme\.com\.tr\/[^"]+/) do |match|
          "<a href=\"#\" id=\"copyButton\" onclick=\"copyToClipboard('#{match.strip}')\">#{match.strip}</a>"
        end

        formatted_artifacts.html_safe
      end

      def self.fetch_repo_names(url = "http://debrepo.ulakhaberlesme.com.tr/api/repos")
        begin
          response = Net::HTTP.get(URI(url))
          repos = JSON.parse(response)

          repo_names = repos.map { |repo| repo["Name"] }
        rescue StandardError => e
          puts "Error occurred: #{e.message}"
          repo_names = [] # Boş dizi döndür
        end

        repo_names
      end

      def self.transform_package_name(input)
        arch, package_name, version, commit_hash = input.split
        arch = arch.sub(/^P/, "").downcase # Pamd64 -> amd64
        "#{package_name}_#{version}_#{arch}.deb"
      end

      def self.fetch_repo_packages(distro_name)
        begin
          url = "http://debrepo.ulakhaberlesme.com.tr/api/repos/#{distro_name}/packages"
          response = Net::HTTP.get(URI(url))
          repo_packages = JSON.parse(response)

          repo_packages = repo_packages.map { |package| transform_package_name(package) }
        rescue StandardError => e
          puts "Error occurred: #{e.message}"
          repo_packages = [] # Boş dizi döndür
        end
        puts ">>>>>> repo packages: #{repo_packages}"
        repo_packages
      end

      def self.fetch_all_packages
        begin
          repo_names = fetch_repo_names()
          all_packages = repo_names.map do |repo_name|
            { "#{repo_name}": fetch_repo_packages(repo_name) }
          end
        rescue StandardError => e
          puts "Error occurred: #{e.message}"
          all_packages = [] # Boş dizi döndür
        end
        puts ">>>>>> all packages: #{all_packages}"
        all_packages
      end
    end # < class IssueAssociatedRevision
  end # < module Hook
end # < module UlakTest
