module MyPlugin
  module Hooks
    class IssueTestsTab < Redmine::Hook::ViewListener
      def view_issues_show_description_bottom1(context = {})
        issue_data = []
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

      def view_issues_form_details_top1(context = {})
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
          partial: "issues/tabs/issue_test_results",
          locals: { issue_data: issue_data },
        })

        output.html_safe
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

      def view_issues_form_details_bottom(context = {})
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
