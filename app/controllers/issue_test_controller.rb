class IssueTestController < ApplicationController
  def remove_test_from_issue
    issue_id = params[:issue_id]
    test_id = params[:test_id]

    self.remove_test_from_issue(issue_id, test_id)
  end

  def self.remove_test_from_issue(issue_id, test_id)
    issue = Issue.find_by(id: issue_id)
    return render json: { error: "Issue not found" }, status: :not_found unless issue

    test = Test.find_by(id: test_id)
    return render json: { error: "Test not found" }, status: :not_found unless test

    issue_test = IssueTest.find_by(issue: issue, test: test)
    return render json: { error: "Test not found in the issue" }, status: :not_found unless issue_test

    issue_test.destroy
    return render json: { message: "#{test.summary} Test removed from issue successfully" }, status: :ok
  end

  def add_test_to_issue
    issue_id = params[:issue_id]
    test_id = params[:test_id]
    self.add_test_to_issue(issue_id, test_id)
  end

  def self.add_test_to_issue(issue_id, test_id)
    issue = Issue.find(issue_id)
    test = Test.find_by(id: test_id)

    # Use the "IssueTest" model to add the relationship
    issue_test = IssueTest.find_or_create_by(issue: issue, test: test)

    # Return a JSON response with the success message
    return render json: {
                    success: true,
                    message: "#{issue.id} Numaralı görev için #{test.id} numaralı test eklendi.",
                  }
  end

  def get_issue_tests
    issue_id = params[:issue_id]
    issue = Issue.find(issue_id)
    return render json: { error: "Issue not found" }, status: :not_found unless issue

    tests = issue.tests.select(:id, :summary)

    # "tests" dizisini istenen formata dönüştürmek için map kullanıyoruz
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
    executions = UlakTest::Kiwi.fetch_testexecution_by_case_id_in(test_case_ids)
    formatted_tests.each { |test| test[:executions] = executions.select { |item| item[:case] == test["id"] } }

    run_ids = []
    #run_ids = executions.pluck(:run)
    executions.select{|exec| run_ids << exec["run"] }
    @runs = UlakTest::Kiwi.fetch_run_by_case_id_in(run_ids)
    Rails.logger.info("test_runs>>" + runs.inspect)

    # runs.each > her koşunun note alanına bak
    # issue->changeset içindeki sürüme ait paket run.note alanında var mı?
    # varsa test senaryosunun durumuna göre template içindeki ok, not-ok göster.
    @issue_data = { issue_id: issue_id, issue_tests: formatted_tests }.to_json

    html_content = render_to_string(
      template: "templates/_issue_test_results.html.erb",
      # layout: false ile tüm Redmine sayfasının derlenMEmesini sağlarız
      layout: false,
    )
    render html: html_content
  end
end
