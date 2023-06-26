module MyPlugin
  module Hooks

    class ViewIssuesShowDetailsBottomHook < Redmine::Hook::ViewListener

      def view_layouts_base_html_head(context = {})
        tags = javascript_include_tag('test_results.js', :plugin => 'my_plugin') + stylesheet_link_tag("test_results.css", :plugin => "my_plugin", :media => "all")
        tags.html_safe
      end

    end

  end
end