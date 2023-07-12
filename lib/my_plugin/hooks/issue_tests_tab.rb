require "action_view"
include ActionView::Helpers::SanitizeHelper

module MyPlugin
  module Hooks
    class IssueTestsTab < Redmine::Hook::ViewListener
      def view_issues_show_details_bottom(context = {})
        Rails.logger.info(">>> IssueTestsTab.view_issues_show_details_bottom <<<<")
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
    end
  end
end
