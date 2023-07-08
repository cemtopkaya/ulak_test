class MyPluginController < ApplicationController
  def remove_test_from_issue
    issue_id = params[:issue_id]
    test_id = params[:test_id]

    issue = Issue.find_by(id: issue_id)
    return render json: { error: "Issue not found" }, status: :not_found unless issue

    test = Test.find_by(id: test_id)
    return render json: { error: "Test not found" }, status: :not_found unless test

    issue_test = IssueTest.find_by(issue: issue, test: test)
    return render json: { error: "Test not found in the issue" }, status: :not_found unless issue_test

    issue_test.destroy
    render json: { message: "#{test.summary} Test removed from issue successfully" }, status: :ok
  end

  def sync_kiwi_test_cases
    all_tests_before = Test.all
    products = MyPlugin::Kiwi.fetch_kiwi_products()
    products.each do |product|
      cases = MyPlugin::Kiwi.fetch_kiwi_test_cases(product["id"])
      Rails.logger.info(">>> cases: #{cases}")
      cases.each do |c|
        test = Test.find_or_create_by({ test_case_id: c["id"], summary: c["summary"], product_id: product["id"], category: c["category"], category_name: c["category__name"] })
        puts "test: #{test}"
      end
    end
    all_tests_after = Test.all

    render json: {
      before: all_tests_before.count,
      after: all_tests_after.count,
    }, status: :ok
  end

  def add_test_to_issue
    issue = Issue.find(params[:issue_id])
    test = Test.find_by(id: params[:test_id])
    Rails.logger.info(">>>> test: #{test}")

    # "IssueTest" modelini kullanarak ilişkiyi ekleyin
    IssueTest.find_or_create_by(issue: issue, test: test)
    # issue.tests << test

    render json: {
             success: true,
             message: "#{issue.id} Numaralı görev için #{test.id} numaralı test eklendi.",
           }
  end

  def get_issue_tests
    issue_id = params[:issue_id]
    issue = Issue.find(params[:issue_id])
    return render json: { error: "Issue not found" }, status: :not_found unless issue

    tests = Test.joins(:issue_tests).where(issue_tests: { issue_id: issue_id })
      .select(:id, :summary) # Sadece testin id ve summary alanlarını seçiyoruz

    # "tests" dizisini istenen formata dönüştürmek için map kullanıyoruz
    # formatted_tests = tests.map { |test| { id: test.id, text: test.summary } }
    formatted_tests = tests.map { |test| { id: test.id, summary: test.summary } }

    Rails.logger.info(">>>> tests: #{tests}")
    render json: formatted_tests, status: :ok
  end

  def get_tests
    issue_id = params[:issue_id]
    q = params[:q]

    if q
      tests = Test
      # .joins(:issue_tests)
      # .where(issue_tests: { issue_id: issue_id })
        .where("tests.summary LIKE ?", "%#{q}%")
        .select(:id, :summary) # Sadece testin id ve summary alanlarını seçiyoruz
    else
      tests = Test
      # .joins(:issue_tests)
      # .where(issue_tests: { issue_id: issue_id })
        .where("tests.summary LIKE ?", "%#{q}%")
        .select(:id, :summary) # Sadece testin id ve summary alanlarını seçiyoruz
    end
    puts tests.to_sql

    render json: tests
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

  def view_issue_test_results
    issue_id = params[:issue_id]
    tests = Test
      .joins(:issue_tests)
      .where(issue_tests: { issue_id: issue_id })
      .select(:id, :summary)
    unless tests.empty?
      formatted_tests = tests.map { |test| { id: test.id, text: test.summary } }
    else
      formatted_tests = []
    end

    test_case_ids = formatted_tests.pluck(:id)
    executions = MyPlugin::Kiwi.fetch_testexecution_by_case_id_in(test_case_ids)
    run_ids = executions.pluck(:run)
    runs = MyPlugin::Kiwi.fetch_run_by_case_id_in(run_ids)

    @issue_data = { issue_id: issue_id, issue_tests: formatted_tests }.to_json

    html_content = render_to_string(
      # /usr/src/redmine/plugins/my_plugin/app/views/my_plugin/my_template.html.erb
      template: "templates/_issue_test_results.html.erb",
      # layout: false ile tüm Redmine sayfasının derlenMEmesini sağlarız
      layout: false,
    )
    render html: html_content
  end
end
