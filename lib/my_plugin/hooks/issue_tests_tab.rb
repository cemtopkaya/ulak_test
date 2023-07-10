module MyPlugin
  module Hooks
    class IssueTestsTab < Redmine::Hook::ViewListener
      def view_issues_form_details_bottom(context = {})
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
            # Wrap the text field with <p></p> tags.
            f.text_field field_name, value: field_value, label: field_label, class: "test_name_input", style: "width:100%;"
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

      def controller_issues_new_before_save(context = {})
        test_name_input = context[:params][:issue][:issue][:test_name_input]
        # set my_attribute on the issue to a default value if not set explictly
        Rails.logger.info(">>> controller_issues_new_before_save  kısmına geldik <<<")
      end

      def controller_issues_edit_after_save(context = {})
        # set my_attribute on the issue to a default value if not set explictly
        Rails.logger.info(">>> controller_issues_edit_after_save  kısmına geldik <<<")
      end

      def controller_issues_edit_before_save(context = {})
        # set my_attribute on the issue to a default value if not set explictly
        Rails.logger.info(">>> controller_issues_edit_before_save  kısmına geldik <<<")
      end

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

      def view_issues_form_details_bottom2(context = {})
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
