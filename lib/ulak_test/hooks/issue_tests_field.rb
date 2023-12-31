require "action_view"
include ActionView::Helpers::SanitizeHelper

module UlakTest
  module Hooks
    class IssueTestsField < Redmine::Hook::ViewListener
      def self.upsert_issue_test(issue_id, project, new_test_ids)
        
        # Check if the user is authorized to view the plugin.
        unless User.current.allowed_to?(:edit_issue_tests, project)
          # The user is not authorized to view the plugin.
          Rails.logger.info(">>> #{User.current.login} does not have permission to view the Issue Edit for Kiwi Tests field, so this tab will not be created... !!!! <<<<")
          return
        end

        old_test_ids = Test
          .joins(:issue_tests)
          .where(issue_tests: { issue_id: issue_id })
          .select(:id, :summary)
          .pluck(:id)

        removed_test_ids = old_test_ids - new_test_ids
        added_test_ids = new_test_ids - old_test_ids

        removed_test_ids.each do |test_id|
          IssueTestController.remove_test_from_issue(issue_id, test_id)
        end

        added_test_ids.each do |test_id|
          IssueTestController.add_test_to_issue(issue_id, test_id)
        end

        journalize_issue_test_change(issue_id, old_test_ids, new_test_ids)
      end

      def controller_issues_new_after_save(context = {})
        process_issue_tests(context)
      end

      def controller_issues_edit_after_save(context = {})
        process_issue_tests(context)
      end

      def view_issues_form_details_bottom(context = {})
        
        # Check if the user is authorized to view the plugin.
        unless User.current.allowed_to?(:edit_issue_tests, context[:issue].project)
          # The user is not authorized to view the plugin.
          Rails.logger.info(">>> #{User.current.login} does not have permission to view the Issue Edit for Kiwi Tests field, so this tab will not be created... !!!! <<<<")
          return
        end

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

        controller = context[:controller]
        label_field = controller.view_context.label_tag(:test_select_input, l(:issue_tests), class: "test_selec_input")
        select_field = controller.view_context.select_tag(:test_select_input, options_for_select(select_options), { label: "Tests", style: "width:100%", class: "test_select_input", multiple: true })

        controller = context[:hook_caller].is_a?(ActionController::Base) ? context[:hook_caller] : context[:hook_caller].controller

        output = controller.send(:render_to_string, {
          partial: "hooks/issues/view_issues_form_details_bottom",
          locals: { select_options: select_options },
        })

        context[:controller].view_context.content_tag(:p) do
          label_field + select_field + output.html_safe
        end
      end

      def view_issues_history_journal_bottom5(context = {})
        journal = context[:journal]
        issue = journal.issue if journal.present? # Issue objesini almak için

        return if issue.blank?

        journals = issue.journals.includes(:details)
        issue_tests_journal = journals.select { |journal| journal.notes == "Test Change" }
        return if issue_tests_journal.empty?

        content = ""
        issue_tests_journal.each do |journal|
          content << context[:controller].view_context.render(
            partial: "hooks/issues/issue_tests_history",
            locals: { journal: journal },
          )
        end

        content.html_safe
      end

      private

      def process_issue_tests(context)
        Rails.logger.info(">>> process_issue_tests kısmına geldik <<<")
        # new_tests = context[:params][:test_select_input].map(&:to_i)
        new_tests = context.dig(:params, :test_select_input)&.map(&:to_i) || []
        issue_id = context[:issue].id
        project = context[:issue].project
        IssueTestsField.upsert_issue_test(issue_id, project, new_tests)
      end

      private

      # def self.journalize_issue_test_change(issue_id, added_test_ids, removed_test_ids)
      def self.journalize_issue_test_change(issue_id, old_test_ids, new_test_ids)
        issue = Issue.find_by(id: issue_id)
        return unless issue

        removed_test_ids = old_test_ids - new_test_ids
        added_test_ids = new_test_ids - old_test_ids

        # eklenen veya silinen yoksa journal değişmesin
        return unless !added_test_ids.empty? || !removed_test_ids.empty?

        added_tests = Test.where(id: added_test_ids).pluck(:summary).join("\n* ")
        removed_tests = Test.where(id: removed_test_ids).pluck(:summary).map { |test| "-#{test}-" }.join("\n* ")

        result = ""
        if !added_tests.empty?
          result += "h5. #{l(:text_issue_tests_added)}\n\n* #{added_tests}\n\n"
        end

        if !removed_tests.empty?
          result += "h5. #{l(:text_issue_tests_removed)}\n\n* #{removed_tests}"
        end

        journal = issue.init_journal(User.current)
        journal.notes = result
        journal.save
      end
    end
  end
end
