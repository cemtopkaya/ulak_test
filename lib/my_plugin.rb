module MyPlugin
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
          return controller.send(:render, {
                   partial: "hooks/issues/view_issues_show_description_bottom",
                   locals: { "@changesets": issue.changesets },
                 })
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

      private

      def view_issues_show_description_bottom1(context = {})
        controller = context[:controller]
        project = context[:project]
        repo_id = controller.params[:repository_id]

        Rails.logger.info(">>>> view_issues_show_description_bottom.... project: #{project}")
        Rails.logger.info(">>>> view_issues_show_description_bottom.... repo_id: #{repo_id}")
        issue = context[:issue]
        changesets = issue.changesets
        Rails.logger.info(">>>> changesets 111: #{changesets}")

        # Değişiklik kümesi varsa, onları kullanmak için @changesets değişkenine atayın.
        # Değişiklik kümesi yoksa, boş bir dizi ile @changesets değişkenini başlatın.
        @changesets = changesets.present? ? changesets : nil
        Rails.logger.info(">>>> changesets 222: #{@changesets}")
        # context[:changesets] = changesets
        # Rails.logger.info(">>>> changesets 333: #{context[:changesets]}")

        if changesets.any?
          # Değişiklik kümesi varsa, burada istediğiniz içeriği oluşturun veya görüntülemek istediğiniz
          # diğer view dosyasının içeriğini buraya ekleyin.
          # return "Değişiklik kümesi var!"

          # render_on_view(:view_issues_show_description_bottom,
          #                :partial => "hooks/issues/view_issues_show_description_bottom",
          #                :locals => { :@changesets => changesets })

          # render_on :view_issues_show_description_bottom,
          #           :partial => "hooks/issues/view_issues_show_description_bottom",
          #           :locals => { :@changesets => changesets }

          # render :view => "hooks/issues/view_issues_show_description_bottom",
          #        :locals => { :@changesets => changesets }

          # render :partial => "hooks/issues/view_issues_show_description_bottom",
          #        :locals => { :@changesets => changesets }

          # render partial: "hooks/issues/view_issues_show_description_bottom",
          #        locals: { changesets: changesets }

          render partial: "hooks/view_issues_show_description_bottom",
                 locals: { changesets: changesets }

          # context[:controller].send(:render_to_string, {
          #   :partial => "hooks/issues/view_issues_show_description_bottom",
          #   :locals => { :@changesets => changesets },
          # # :locals => context,
          # })
        else
          # Değişiklik kümesi yoksa, burada başka içerik oluşturabilir veya başka bir view dosyasının içeriğini ekleyebilirsiniz.
          return "Değişiklik kümesi yok!"
        end

        # context[:controller].send(:render_to_string, context, {}, nil)
      end

      private

      def dd_view_issues_show_description_bottom(context = {})
        issue = context[:issue]
        changesets = issue.changesets
      end

      def ccc_view_issues_show_description_bottom(context = {})
        controller = context[:controller]
        project = context[:project]
        repo_id = controller.params[:repository_id]

        Rails.logger.info(">>>> view_issues_show_description_bottom.... project: #{project}")
        Rails.logger.info(">>>> view_issues_show_description_bottom.... repo_id: #{repo_id}")
        issue = context[:issue]
        changesets = issue.changesets
        Rails.logger.info(">>>> changesets: #{changesets}")
        # @changesets = changesets if changesets.any?
        context[:changesets] = changesets if changesets.any?
        @changesets = changesets || []

        #-------------------
        # @changesets = changesets if changesets.any?
        # controller = context[:controller]
        # view_context = controller.view_context
        # view_context.assign(issue: issue, changesets: changesets)
        # sonuc = view_context.render(template: "hooks/issues/view_issues_show_description_bottom", layout: false)
        # return sonuc
        #-------------------

        # body = calistir(context, issue)
        # Rails.logger.info(">>>> body: #{body}")
        # context[:hook_caller].output_buffer << body
        # context[:controller].send(:render_to_string, {
        context[:controller].send(:render_to_string, {
          :partial => "hooks/issues/view_issues_show_description_bottom",
          :locals => context,
        })
      end

      def calistir(context, issue)
        changesets = issue.changesets
        Rails.logger.info(">>>> changesets: #{changesets}")
        @changesets = changesets if changesets.any?

        data = {
          issue: issue,
          changesets: @changesets,
        }
        controller = context[:controller]
        view_context = controller.view_context
        view_context.assign(issue: issue, changesets: @changesets)

        # hooks/issues altındaki view'i render etmek için render kullanın.
        sonuc = view_context.render(template: "view_issues_show_description_bottom", layout: false)
        return sonuc

        # render partial: "hooks/issues/view_issues_show_description_bottom", locals: data
      end
    end

    # class ViewIssuesShowDescriptionBottomHook < Redmine::Hook::ViewListener
    #   def view_issues_show_description_bottom(context = {})
    #     Rails.logger.info(">>>> view_issues_show_description_bottom....")
    #     issue = context[:issue]
    #     body = calistir(context, issue)
    #     Rails.logger.info(">>>> body: #{body}")
    #     context[:hook_caller].output_buffer << body.html_safe
    #   end

    #   private

    #   def calistir(context, issue)
    #     changesets = issue.changesets
    #     Rails.logger.info(">>>> changesets: #{changesets}")
    #     @changesets = changesets if changesets.any?

    #     # ActionController ve ActionView nesnelerine erişmek için kullanın.
    #     controller = context[:controller]
    #     view_context = controller.view_context
    #     view_context.assign(issue: issue, changesets: @changesets)

    #     # hooks/issues altındaki view'i render etmek için render kullanın.
    #     return view_context.render(
    #              template: "hooks/issues/view_issues_show_description_bottom",
    #              layout: false,
    #            )
    #   end
    # end

    # class ViewIssuesShowDescriptionBottomHook < Redmine::Hook::ViewListener
    #   include Redmine::I18n
    #   # render_on :view_issues_show_description_bottom,
    #   #           :partial => "hooks/issues/view_issues_show_description_bottom"

    #   def view_issues_show_description_bottom(context = {})
    #     # return content_tag("p", "Custom content added to the right")
    #     issue = context[:issue]
    #     changesets = issue.changesets
    #     Rails.logger.info(">>>> changesets: #{changesets}")
    #     context[:changesets] = changesets if changesets.any?
    #     return render partial: "hooks/issues/view_issues_show_description_bottom"

    #     # render_on(
    #     #   :view_issues_show_description_bottom,
    #     #   :partial => "hooks/issues/view_issues_show_description_bottom",
    #     #   :layout => false,
    #     # )

    #     # # 1. ActionView::Base sınıfından türetilmiş bir örnek oluşturun
    #     # view = ActionView::Base.new(ActionController::Base.view_paths, {})

    #     # # 2. Şablonu çağırın ve elde edilen çıktıyı output değişkenine atayın
    #     # output = view.render(
    #     #   :partial => "hooks/issues/view_issues_show_description_bottom",
    #     #   :locals => context,
    #     # )

    #     @changesets = changesets if changesets.any?

    #     output = render partial: "hooks/issues/view_issues_show_description_bottom"

    #     context[:hook_caller].output_buffer << output
    #   end
    # end

    # class ViewIssuesShowDescriptionBottomHook < Redmine::Hook::ViewListener
    #   include Redmine::I18n
    #   render_on :view_issues_show_description_bottom, partial: "hooks/issues/view_issues_show_description_bottom"

    #   def view_issues_show_description_bottom(context = {})
    #     issue = context[:issue]
    #     changesets = issue.changesets
    #     Rails.logger.info(">>>> changesets: #{changesets}")
    #     context[:changesets] = changesets if changesets.any?
    #   end
    # end

    class OylesineBirSinif < Redmine::Hook::ViewListener
      def view_layouts_base_html_head(context = {})
        controller = context[:request].parameters[:controller]
        action = context[:request].parameters[:action]
        Rails.logger.info(">>> MyPlugin.OylesineBirSinif.view_layouts_base_html_head >>> controller: #{controller}>>> action: #{action}")

        return nil unless controller == "issues" && action == "show"

        issue_id = context[:request].params[:id]
        return nil unless issue_id.present? && issue_id.to_i.to_s == issue_id

        tags = javascript_include_tag(
          "test_results.js",
          :plugin => "my_plugin",
        ) + stylesheet_link_tag(
          "test_results.css",
          :plugin => "my_plugin",
          :media => "all",
        )

        # Eğer sayfa "issues" sayfası ise devam edelim, aksi halde hiçbir içerik eklemeyelim
        Rails.logger.info(">>>> issue_id 1: #{issue_id}")
        issue_data = get_issue(issue_id)
        # Diğer JavaScript kodunu ekleyelim
        additional_js = javascript_tag(
          %Q(
              // Burada başka JavaScript kodları olabilir
              console.log("The details of the issue can be accessed through the 'issueData' variable");
              var issueData = #{issue_data};
            )
        )

        tags.html_safe + additional_js
      end

      private

      def get_issue(issue_id)
        # Burada issue_id değerini alıp testlerini çekeceğiz
        Rails.logger.info(">>>> issue_id 2: #{issue_id}")
        issue = Issue.find(issue_id)

        tests = Test.joins(:issue_tests).where(issue_tests: { issue_id: issue_id }).select(:id, :test_name)
        formatted_tests = tests.map { |test| { id: test.id, text: test.test_name } }
        issue_data = { issue_id: issue_id, issue_tests: formatted_tests }.to_json
        return issue_data
      end
    end
  end
end
