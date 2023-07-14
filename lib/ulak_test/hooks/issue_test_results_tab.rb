require "action_view"
include ActionView::Helpers::SanitizeHelper

module UlakTest
  module Hooks
    class IssueTestResultsTab < Redmine::Hook::ViewListener
      def view_issues_show_details_bottom(context = {})
        Rails.logger.info(">>> IssueTestResultsTab.view_issues_show_details_bottom <<<<")
        issue = context[:issue]
        return render json: { error: "Issue not found" }, status: :not_found unless issue

        tests = Test
          .joins(:issue_tests)
          .where(issue_tests: { issue_id: issue.id })
          .select(:id, :summary)

        issue_data = { tests: tests, issue_id: issue.id }

        unless tests.blank?
          hook_caller = context[:hook_caller]
          controller = hook_caller.is_a?(ActionController::Base) ? hook_caller : hook_caller.controller

          output = controller.send(:render_to_string, {
            partial: "issues/tabs/tab_issue_test_results",
            locals: {
                      tab_issue_assoc_revisions: {
                        issue_data: issue_data.to_json,
                      },
                      tab_test_results: {
                        issue_id: issue.id,
                        issue: issue,
                        tests: tests.to_json,
                      },
                    },
          })

          output
        end
      end
    end
  end
end
