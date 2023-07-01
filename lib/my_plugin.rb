module MyPlugin
  module Hooks
    class OylesineBirSinif < Redmine::Hook::ViewListener
      def view_layouts_base_html_head(context = {})
        controller = context[:request].parameters[:controller]
        action = context[:request].parameters[:action]
        Rails.logger.info(">>> MyPlugin.OylesineBirSinif.view_layouts_base_html_head >>> controller: #{controller}>>> action: #{action}")

        return nil unless controller == "issues" && action == "show"

        issue_id = context[:request].params[:id]
        return nil unless issue_id.present? && issue_id.to_i.to_s == issue_id

        # Eğer sayfa "issues" sayfası ise devam edelim, aksi halde hiçbir içerik eklemeyelim
        Rails.logger.info(">>>> issue_id 1: #{issue_id}")
        issue_data = get_issue(issue_id)
        tags = javascript_include_tag(
          "test_results.js",
          :plugin => "my_plugin",
        ) + stylesheet_link_tag(
          "test_results.css",
          :plugin => "my_plugin",
          :media => "all",
        )
        # Diğer JavaScript kodunu ekleyelim
        additional_js = javascript_tag(
          %Q(
                // Burada başka JavaScript kodları olabilir
                console.log('Additional JavaScript code');
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

      def get_issue1(issue_id)
        # Burada issue_id değerini alıp testlerini çekeceğiz
        Rails.logger.info(">>>> issue_id: #{issue_id}")
        issue = Issue.find(issue_id)

        tests = Test.joins(:issue_tests).where(issue_tests: { issue_id: issue_id }).select(:id, :test_name)
        formatted_tests = tests.map { |test| test.test_name }
        issue_data = { issue_id: issue_id, issue_tests: formatted_tests }.to_json
        return issue_data
        # javascript_tag("var issueData = #{issueData};")
        # tags = javascript_tag(
        #   %Q(
        #     var issueData = #{issue_data};
        #   )
        # )

        # tags.html_safe
      end
    end
  end
end
