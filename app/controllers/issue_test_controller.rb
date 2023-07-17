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

  def create_run_test_cases(run_id, cwa, formatted_tests)
    cem = formatted_tests.select { |test| test[:run].any? { |run| run[:id] == run_id } }
    puts cem
    # .map { |t| { :id => t[:id], :summary => t[:text], :status => t } }
    # [
    #   {
    #     :id => 110,
    #     :summary => "NG Setup Request",
    #     :test_result => {
    #       :status => "GEÇTİ",
    #     },
    #   },
    # ]
  end

  def create_run_object(run_id, cwa, formatted_tests)
    aykut = {
      :id => run_id,
      :artifacts => cwa[:artifact_full_names].select { |item| item[:run_ids].include?(run_id) }.map { |item| item[:artifact_full_name] },
      :test_cases => create_run_test_cases(run_id, cwa, formatted_tests),
    }
    puts aykut
  end

  # Test senaryolarının execute edilen koşuları bulur ve bu koşuların etiketlerinde geçen
  # paket_adı=versiyon değerini arar. Bulduklarını paketin olduğu test sonuçları olarak görüntüler.

  def view_issue_test_results
    # 1. issue_id ile ilişkili test senaryolarını getir
    # 2. test senaryolarının çalıştırıldığı koşuları bul
    # 3. koşuların etiketlerinde paketi ara (paketin olduğu koşuları süz)
    # 4. "paket olduğu koşuların içindeki" senaryoların durumlarına göre sayfayı render et

    # 1
    issue_id = params[:issue_id]
    tests = Test
      .joins(:issue_tests)
      .where(issue_tests: { issue_id: issue_id })
      .select(:test_case_id, :summary)

    issue = Issue.find(issue_id)
    commit_with_artifacst = UlakTest::Git.findTagsOfCommits(issue.changesets)

    # html_content = controller.send(:render_to_string, {
    #   partial: "templates/_issue_test_results.html.erb",
    #   layout: false,
    #   locals: {
    #     changesets: changesets,
    #   },
    # })
    html_content = render_to_string(
      template: "templates/_tab_content_issue_test_results.html.erb",
      # layout: false ile tüm Redmine sayfasının derlenMEmesini sağlarız
      layout: false,
      locals: {
        commit_with_artifacst: commit_with_artifacst,
        issue_id: issue_id,
        tests: tests,
      },
    )
    render html: html_content
  end
end
