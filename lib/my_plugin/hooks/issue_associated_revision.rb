require "yaml"

module MyPlugin
  module Hooks
    class IssueAssociatedRevision < Redmine::Hook::ViewListener
      def view_issues_show_details_bottom(context = {})
        issue = context[:issue]
        associated_revisions = findTagsOfCommits(issue)

        hook_caller = context[:hook_caller]
        controller = hook_caller.is_a?(ActionController::Base) ? hook_caller : hook_caller.controller
        output = controller.send(:render_to_string, {
          partial: "issues/tabs/issue_associated_revision",
          locals: { "@changesets": issue.changesets, artifacts: associated_revisions },
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
    end # < class IssueAssociatedRevision
  end # < module Hook
end # < module MyPlugin
