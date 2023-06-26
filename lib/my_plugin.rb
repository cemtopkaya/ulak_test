module MyPlugin
  module Hooks
    class ViewIssuesShowDetailsBottomHook < Redmine::Hook::ViewListener
      include Redmine::I18n
      render_on(
        :view_issues_show_details_bottom,
        :partial => 'hooks/issues/view_issues_form_details_bottom',
        :layout => false
      )
    end
    class ViewIssuesShowSidebarBottomHook < Redmine::Hook::ViewListener
      include Redmine::I18n
      render_on(
        :view_issues_show_sidebar_bottom,
        :partial => 'hooks/issues/view_issues_show_sidebar_bottom',
        :layout => false
      )
    end
    
    class ViewIssuesShowDescriptionBottomHook < Redmine::Hook::ViewListener
      include Redmine::I18n
      render_on(
        :view_issues_show_description_bottom,
        :partial => 'hooks/issues/view_issues_show_description_bottom',
        :layout => false
      )
    end
    
    class ViewIssuesContextMenuEndHook < Redmine::Hook::ViewListener
      include Redmine::I18n
      render_on(
        :view_issues_context_menu_end,
        :partial => 'hooks/issues/view_issues_context_menu_end',
        :layout => false
      )
    end
    
    class ViewLayoutsBaseSidebarHook < Redmine::Hook::ViewListener
      include Redmine::I18n
      render_on(
        :view_layouts_base_sidebar,
        :partial => 'hooks/layouts/view_layouts_base_sidebar',
        :layout => false
      )
    end
    
    class ViewProjectsShowSidebarBottomHook < Redmine::Hook::ViewListener
      include Redmine::I18n
      render_on(
        :view_projects_show_sidebar_bottom,
        :partial => 'hooks/projects/view_projects_show_sidebar_bottom',
        :layout => false
      )
    end
  end
end