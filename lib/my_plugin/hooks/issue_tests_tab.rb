module MyPlugin
  module Hooks
    class IssueTestsTab < Redmine::Hook::ViewListener
      def self.upsert_issue_test(issue_id, new_tests)
        old_tests = Test
          .joins(:issue_tests)
          .where(issue_tests: { issue_id: issue_id })
          .select(:id, :summary)
          .pluck(:id)

        removed_tests = old_tests - new_tests
        added_tests = new_tests - old_tests

        removed_tests.each do |test_id|
          IssueTestController.remove_test_from_issue(issue_id, test_id)
        end

        added_tests.each do |test_id|
          IssueTestController.add_test_to_issue(issue_id, test_id)
        end
      end

      def controller_issues_new_after_save(context = {})
        process_issue_tests(context)
      end

      def controller_issues_edit_after_save(context = {})
        process_issue_tests(context)
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
          select_options = tests.map { |t| [t.summary, t.id, selected: "selected"] }
        end

        label_field = context[:controller].view_context.label_tag(:test_select_input, "Issue Tests", class: "test_selec_input")
        # select_field = context[:controller].view_context.select_tag(:test_select_input, options_for_select(select_options), label: "Tests", class: "test_selec_input")
        select_field = context[:controller].view_context.select_tag(:test_select_input, options_for_select(select_options), { label: "Tests", style: "width:100%", class: "test_select_input", multiple: true })

        controller = context[:hook_caller].is_a?(ActionController::Base) ? context[:hook_caller] : context[:hook_caller].controller

        output = controller.send(:render_to_string, {
          partial: "hooks/issues/cem_deneme",
          locals: { select_options: select_options },
        })

        context[:controller].view_context.content_tag(:p) do
          label_field + select_field + output.html_safe
        end
      end

      private

      def process_issue_tests(context)
        Rails.logger.info(">>> process_issue_tests kısmına geldik <<<")
        new_tests = context[:params][:test_select_input].map(&:to_i)
        issue_id = context[:issue].id
        IssueTestsTab.upsert_issue_test(issue_id, new_tests)
      end
    end
  end
end
