class MyPluginController < ApplicationController
  def index
    # :issue_id Değerini params ile alıyoruz ve Issue.find ile 
    # tüm ayrıntılarını çekiyoruz.
    # get 'my_plugin/:issue_id', to: 'my_plugin#index'
    issue = Issue.find(params[:issue_id])
    Rails.logger.info(">>>>> issue : #{issue}")
    
    # Sayfaya bağlayacağımız veriyi burada ayarlıyoruz
    @data = {
      content: "content alanı",
      created_at: "created at alanı",
      id: 123
    }
    
    # Tüm Redmine sayfasını döner
    # respond_to do |format|
    #   format.html { render 'my_plugin/my_template.html.erb' }
    #   format.json { render json: @data }
    # end
    
    html_content = render_to_string(
      # /usr/src/redmine/plugins/my_plugin/app/views/my_plugin/my_template.html.erb
      template: 'templates/test_results.html.erb', 
      # layout: false ile tüm Redmine sayfasının derlenMEmesini sağlarız 
      layout: false 
    )
    
    # render json: { html_content: html_content, data: @data }
    render html: html_content
  end

end
