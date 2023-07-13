module UlakTest
  module Hooks
    class ViewIssuesShowDescriptionBottomHook < Redmine::Hook::ViewListener
      render_on :view_issues_show_description_bottom,
                partial: "hooks/issues/view_issues_show_description_bottom",
                locals: { changesets: @changesets } do
        "<p>Özel içerik burada.</p>".html_safe
      end

      def view_issues_show_description_bottom(context = {})
        issue = context[:issue]
        if issue.changesets.any?
          # Değişiklik kümesi varsa, burada istediğiniz içeriği oluşturun veya görüntülemek istediğiniz
          # diğer view dosyasının içeriğini buraya ekleyin.
          # return "Değişiklik kümesi var!"
          Rails.logger.info(">>>> Render_on block is executed with changesets #{context[:hook_caller]}")
          # return nil # Bu satırı ekleyerek render_on bloğuna düşmesini sağlarız

          # context[:hook_caller].send(:render_on,
          #                            :view_issues_show_description_bottom,
          #                            partial: "hooks/issues/view_issues_show_description_bottom",
          #                            locals: { changesets: @changesets })

          # context[:hook_caller].send(:render, {
          #   :partial => "hooks/issues/view_issues_show_description_bottom",
          #   :locals => { changesets: @changesets },
          # })
          hook_caller = context[:hook_caller]

          # If the hook was triggered by a controller action, then `hook_caller` will be the controller instance.
          if hook_caller.is_a?(ActionController::Base)
            Rails.logger.info(">>>> hook_caller: #{hook_caller}")
            controller = hook_caller
          else
            # If the hook was triggered by something else, then `hook_caller` will be the object that triggered the hook.
            Rails.logger.info(">>>> controller: #{hook_caller.is_a?(ActionController::Base)}")
            controller = hook_caller.controller
          end

          #----------------- ÇALIŞIYOR -> ----------------------
          # return controller.send(:render_to_string, {
          #          partial: "hooks/issues/view_issues_show_description_bottom",
          #          locals: { "@changesets": issue.changesets },
          #        })
          #----------------- <- ÇALIŞIYOR ----------------------

          #----------------- ÇALIŞIYOR ----------------------
          # return controller.send(:render, {
          #          partial: "hooks/issues/view_issues_show_description_bottom",
          #          locals: { "@changesets": issue.changesets },
          #        })
          #----------------- <- ÇALIŞIYOR ----------------------

          #----------------- ÇALIŞmadı -> ----------------------
          # return controller.send(:render_component,
          #                        "hooks/issues/view_issues_show_description_bottom",
          #                        { "@changesets": issue.changesets })
          #----------------- <- ÇALIŞmadı ----------------------

          #----------------- ÇALIŞmadı ----------------------
          # return controller.send("render_on", :view_issues_show_description_bottom,
          #                        partial: "hooks/issues/view_issues_show_description_bottom",
          #                        locals: { "@changesets": issue.changesets })
          #----------------- <- ÇALIŞmadı ----------------------

          #----------------- ÇALIŞmadı -> ----------------------
          # return controller.send(:render_inline, {
          #          partial: "hooks/issues/view_issues_show_description_bottom",
          #          locals: { "@changesets": issue.changesets },
          #        })
          #----------------- <- ÇALIŞmadı ----------------------

          Rails.logger.info("<<<< >>>> 'return nil' öncesi ----------------")
          return nil
        end

        Rails.logger.info(">>>> last ........")
        return nil # Bu satırı ekleyerek render_on bloğuna düşmesini sağlarız
      end
    end
  end
end
