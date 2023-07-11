module MyPlugin
  module Hooks
    class IssueTestsTab < Redmine::Hook::ViewListener
      render_on :view_issues_form_details_bottom,
                :inline => <<~VIEW
                  <% Rails.logger.info(">>>> <<<<< render_on") %>
                  <% content_for :header_tags do %>
                    <%= javascript_include_tag 'issue_edit_test.js', :plugin => 'my_plugin' %>
                    <%= stylesheet_link_tag 'issue_tests_tab.css', :plugin => 'my_plugin' %>
                  <% end %>
                  
                  <p>ContentForInsideHook content</p>
                VIEW

      def controller_issues_new_before_save(context = {})
        # set my_attribute on the issue to a default value if not set explictly
        Rails.logger.info(">>> controller_issues_new_before_save  kısmına geldik <<<")
      end

      def controller_issues_new_after_save(context = {})
        # set my_attribute on the issue to a default value if not set explictly
        Rails.logger.info(">>> controller_issues_new_after_save  kısmına geldik <<<")
      end

      def controller_issues_edit_before_save(context = {})
        # set my_attribute on the issue to a default value if not set explictly
        Rails.logger.info(">>> controller_issues_edit_before_save  kısmına geldik <<<")
      end

      def controller_issues_edit_after_save(context = {})
        issue_id = context[:issue].id
        test_name_input = context[:params][:test_name_input]
        # set my_attribute on the issue to a default value if not set explictly
        Rails.logger.info(">>> controller_issues_edit_after_save  kısmına geldik <<<")
      end

      def view_issues_form_details_bottom(context = {})
        if context[:issue].new_record?
          select_options = []
        else
          issue = context[:issue]
          tests = Test
            .joins(:issue_tests)
            .where(issue_tests: { issue_id: issue.id })
            .select(:id, :summary)
          # seçilmiş testlet buna benzer olacak > select_options = [["Option 1", "1"], ["Option 2", "2"],...]
          select_options = tests.map { |t| [t.summary, t.id] }
        end

        script_src = ActionController::Base.helpers.asset_path("my_plugin/assets/javascripts/issue_edit_test.js")
        script_tag = context[:controller].view_context.content_tag(:script, nil, src: script_src)

        label_field = context[:controller].view_context.label_tag(:test_select_input, "Issue Tests", class: "test_selec_input")
        select_field = context[:controller].view_context.select_tag(:test_select_input, options_for_select(select_options), label: "Tests", class: "test_selec_input")
        context[:controller].view_context.content_tag(:p) do
          script_tag + label_field + select_field
        end

        hook_caller = context[:hook_caller]
        # If the hook was triggered by a controller action, then `hook_caller` will be the controller instance.
        if hook_caller.is_a?(ActionController::Base)
          controller = hook_caller
        else
          # If the hook was triggered by something else, then `hook_caller` will be the object that triggered the hook.
          controller = hook_caller.controller
        end

        output = controller.send(:render_to_string, {
          partial: "hooks/issues/cem_deneme",
        })

        output.html_safe
      end

      def view_issues_form_details_bottom2(context = {})
        if context[:issue].new_record?
          # JavaScript kodunu ekle
          javascript_code = <<-JS
            console.log('The JavaScript code has been rendered!');
            if (typeof $.fn.select2 === 'undefined') {
              $.getScript('https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/js/select2.full.min.js', function() { 
                var link = document.createElement('link');
                link.href = 'https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.6-rc.0/css/select2.min.css';
                link.rel = 'stylesheet';
                link.type = 'text/css';
                document.head.appendChild(link);
              });
            }
          JS

          # context[:controller].view_context.javascript_tag(javascript_code)
          context[:controller].view_context.javascript_tag(javascript_code, type: :js, defer: true)

          field_name = "test_name_input"
          field_label = l(:issue_tests)
          field_value = ""

          context[:form].fields_for :issue do |f|
            # f.text_field field_name, value: field_value, label: field_label, class: "test_name_input", style: "width:100%;"
            f.hidden_field field_name, value: field_value, class: "test_name_input"
          end
        end
      end

      # def view_issues_form_details_bottom(context = {})
      #   if context[:issue].new_record?
      #     field_name = :my_custom_field
      #     field_label = "My Custom Field"
      #     field_options = [["Option 1", "1"], ["Option 2", "2"], ["Option 3", "3"]]

      #     f = context[:form]

      #     f.label field_name, field_label
      #     f.select field_name, field_options, { :multiple => true }
      #   end
      # end

      def view_issues_show_details_bottom(context = {})
        issue = context[:issue]
        return render json: { error: "Issue not found" }, status: :not_found unless issue

        tests = Test
          .joins(:issue_tests)
          .where(issue_tests: { issue_id: issue.id })
          .select(:id, :summary)

        issue_data = { tests: tests, issue_id: issue.id }

        if !tests.blank?
          hook_caller = context[:hook_caller]
          controller = hook_caller.is_a?(ActionController::Base) ? hook_caller : hook_caller.controller

          output = controller.send(:render_to_string, {
            partial: "issues/tabs/issue_test_results",
            locals: { issue_data: issue_data.to_json },
          })

          output
        end
      end

      def view_issues_form_details_bottom3(context = {})
        issue_id = context[:request].params[:id]
        tests = Test
          .joins(:issue_tests)
          .where(issue_tests: { issue_id: issue_id })
          .select(:id, :summary)

        unless tests.empty?
          formatted_tests = tests.map { |test| { id: test.id, text: test.summary } }
        else
          formatted_tests = []
        end

        issue_data = { issue_id: issue_id, issue_tests: formatted_tests }.to_json

        hook_caller = context[:hook_caller]
        # If the hook was triggered by a controller action, then `hook_caller` will be the controller instance.
        if hook_caller.is_a?(ActionController::Base)
          controller = hook_caller
        else
          # If the hook was triggered by something else, then `hook_caller` will be the object that triggered the hook.
          controller = hook_caller.controller
        end

        output = controller.send(:render_to_string, {
          partial: "hooks/issues/view_issues_form_details_bottom",
          locals: { issue_data: issue_data },
        })

        output.html_safe
      end
    end
  end
end
