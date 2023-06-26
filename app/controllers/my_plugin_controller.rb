class MyPluginController < ApplicationController
  def index
    issue = Issue.find(params[:issue_id])
    Rails.logger.info(">>>>> issue : #{issue}")
    
    @data = {
      content: "content alanı",
      created_at: "created at alanı",
      id: 123
    }
    
    html_content = render_to_string(
      # /usr/src/redmine/plugins/my_plugin/app/views/my_plugin/my_template.html.erb
      template: 'templates/test_results.html.erb', 
      # layout: false ile tüm Redmine sayfasının derlenMEmesini sağlarız 
      layout: false 
    )
    render html: html_content
  end

end
