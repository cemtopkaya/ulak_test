class MyPluginController < ApplicationController
  def remove_test_from_issue
    issue_id = params[:issue_id]
    test_name = params[:test_name]

    issue = Issue.find_by(id: issue_id)
    return render json: { error: "Issue not found" }, status: :not_found unless issue

    test = Test.find_by(test_name: test_name)
    return render json: { error: "Test not found" }, status: :not_found unless test

    issue_test = IssueTest.find_by(issue: issue, test: test)
    return render json: { error: "Test not found in the issue" }, status: :not_found unless issue_test

    issue_test.destroy
    render json: { message: "Test removed from issue successfully" }, status: :ok
  end

  def add_test_to_issue
    issue = Issue.find(params[:issue_id])
    test = Test.find_or_create_by(test_name: params[:test_name])
    Rails.logger.info(">>>> test: #{test}")

    # "IssueTest" modelini kullanarak ilişkiyi ekleyin
    IssueTest.create(issue: issue, test: test)
    # issue.tests << test

    render json: { success: true }
  end

  def get_issue_tests
    issue_id = params[:issue_id]
    issue = Issue.find(params[:issue_id])
    return render json: { error: "Issue not found" }, status: :not_found unless issue

    tests = Test.joins(:issue_tests).where(issue_tests: { issue_id: issue_id })
      .select(:id, :test_name) # Sadece testin id ve test_name alanlarını seçiyoruz

    # "tests" dizisini istenen formata dönüştürmek için map kullanıyoruz
    # formatted_tests = tests.map { |test| { id: test.id, text: test.test_name } }
    formatted_tests = tests.map { |test| test.test_name }

    Rails.logger.info(">>>> tests: #{tests}")
    render json: formatted_tests, status: :ok
  end

  def get_tests
    result = []
    # Burada sunucu tarafında yapılması gereken işlemleri gerçekleştirin ve dizi verilerini elde edin
    data = ["KT_CN_001", "KT_CN_002", "KT_CN_003", "KT_CN_004"]

    q = params[:q]
    if q
      filtered_data = data.select { |item| item.include?(q) }
      puts filtered_data
      result = filtered_data
    end

    render json: result
  end

  def index
    issue = Issue.find(params[:issue_id])
    Rails.logger.info(">>>>> issue : #{issue}")

    @data = {
      content: "content alanı",
      created_at: "created at alanı",
      id: 123,
    }

    html_content = render_to_string(
      # /usr/src/redmine/plugins/my_plugin/app/views/my_plugin/my_template.html.erb
      template: "templates/test_results.html.erb",
      # layout: false ile tüm Redmine sayfasının derlenMEmesini sağlarız
      layout: false,
    )
    render html: html_content
  end
end
