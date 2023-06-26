module MyPlugin
  module Hooks
    class ViewIssuesShowDetailsBottomHook < Redmine::Hook::ViewListener
      include Redmine::I18n      
      # render_on(:view_issues_show_details_bottom, 
      render_on(:view_issues_show_details_bottom, 
        :partial => 'issues/view_issues_form_details_bottom_cem',
        :layout => false)
    end
  end
end