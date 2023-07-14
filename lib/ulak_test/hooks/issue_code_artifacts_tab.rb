require "yaml"
require "net/http"
require "json"

module UlakTest
  module Hooks
    class IssueCodeArtifactsTab < Redmine::Hook::ViewListener
      def view_issues_show_details_bottom(context = {})
        Rails.logger.info(">>> IssueAssociatedRevision.view_issues_show_details_bottom <<<<")
        issue = context[:issue]
        associated_revisions = Git.findTagsOfCommits(issue.changesets)

        # deb Paketlerini yükleyebileceğimiz sunucuların listesini çekiyoruz
        vnf_servers = UlakTest::Jenkins.get_environments_by_arch("VNF")
        cnf_servers = UlakTest::Jenkins.get_environments_by_arch("CNF")

        jenkins_url = "https://jenkins-5gcn.ulakhaberlesme.com.tr"
        job = "view/DevOps/job/DevOps/job/5GCN-Deployment"
        job_token = "5gcn_deploy"

        hook_caller = context[:hook_caller]
        controller = hook_caller.is_a?(ActionController::Base) ? hook_caller : hook_caller.controller

        output = controller.send(:render_to_string, {
          partial: "issues/tabs/tab_issue_code_artifacts",
          locals: {
            issue: issue,
            issue_id: issue.id,
            changesets: associated_revisions,
            vnf_servers: vnf_servers,
            cnf_servers: cnf_servers,
            jenkins: {
              url: jenkins_url,
              job: job,
              job_token: job_token,
            },
          },
        })

        output
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
