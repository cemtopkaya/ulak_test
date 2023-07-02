module MyPlugin
  module Hooks
    class IssueTestsTab < Redmine::Hook::ViewListener
      def view_issues_show_description_bottom(context = {})
        issue_id = context[:request].params[:id]
        tests = Test.joins(:issue_tests).where(issue_tests: { issue_id: issue_id }).select(:id, :test_name)
        formatted_tests = tests.map { |test| { id: test.id, text: test.test_name } }
        issue_data = { issue_id: issue_id, issue_tests: formatted_tests }.to_json

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
        output = controller.send(:render_to_string, {
          partial: "issues/tabs/issue_tests",
          locals: { issueData: issue_data },
        })
        Rails.logger.info(">>>>> return: #{output}")
        output.html_safe
      end
    end
  end
end
