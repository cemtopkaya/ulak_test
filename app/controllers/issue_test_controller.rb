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

    # Check if the user is authorized to view the plugin.
    unless User.current.allowed_to?(:get_issue_tests, issue.project)
      # The user is not authorized to view the plugin.
      Rails.logger.info(">>> #{User.current.login} does not have permission to get issue's tests will not be fetched... !!!! <<<<")
      return
    end

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

  # Test senaryolarının execute edilen koşuları bulur ve bu koşuların etiketlerinde geçen
  # paket_adı=versiyon değerini arar. Bulduklarını paketin olduğu test sonuçları olarak görüntüler.

  def view_tag_runs
    
    tag = params[:tag]
    changeset_id = params[:changeset_id]
    issue_id = params[:issue_id]

    @issue = Issue.find(issue_id)

    # Check if the user is authorized to view the plugin.
    unless User.current.allowed_to?(:view_tag_runs, @issue.project)
      # The user is not authorized to view the plugin.
      Rails.logger.info(">>> #{User.current.login} does not have permission to view the Issue Edit for Kiwi Tests field, so this tab will not be created... !!!! <<<<")
      @error_message = "Kullanıcının bu bilgiye erişme yetkisi yok!"
      html_content = render_to_string(
        template: "errors/401",
        layout: false,
      )
      return render html: html_content
    end
        
    # Check if the user is authorized to view the plugin.
    unless User.current.allowed_to?(:view_tag_runs, @issue.project)
      # The user is not authorized to view the plugin.
      Rails.logger.info(">>> #{User.current.login} does not have permission to view the Tags of Runs will not be fetched... !!!! <<<<")
      return
    end

    @cs = @issue.changesets.find_by_id(changeset_id)

    begin
      @tests = Test
        .joins(:issue_tests)
        .where(issue_tests: { issue_id: issue_id })
        .select(:test_case_id, :summary)  
      @test_ids = @tests.pluck(:test_case_id)

      @artifacts = UlakTest::Git.tag_artifacts(@cs.repository.url, tag)
      if @artifacts.empty? 
        @tag_description = UlakTest::Git.tag_description(@cs.repository.url, tag)
      end
      @edited_artifacts = @artifacts.map { |a| a.end_with?(".deb") ? "#{a.split("_")[0]}=#{a.split("_")[1]}" : a }
      result = UlakTest::Kiwi.is_kiwi_accessable()
      
      if !result[:is_accessable]
        render json: result
        return
      end

      # tag -> runs
      @kiwi_tags = @edited_artifacts.map { |a| UlakTest::Kiwi.fetch_tags_by_tag_name(a) }.flatten
      
      @kiwi_run_ids = @kiwi_tags.pluck("run")
      @kiwi_runs = UlakTest::Kiwi.fetch_runs_by_id_in(@kiwi_run_ids)
      @kiwi_executions = UlakTest::Kiwi.fetch_testexecution_by_run_id_in_case_id_in(@kiwi_run_ids, @test_ids)
      # executions -> run_id_in & case_id_in 

      html_content = render_to_string(
        template: "templates/_tab_test_results.html.erb",
        # layout: false ile tüm Redmine sayfasının derlenMEmesini sağlarız
        layout: false,
        locals: {
          issue_id: issue_id
        },
      )
      render html: html_content  
    rescue SocketError => e
      @error_message = "#{l(:text_exception_name)}: #{e.message}"
      render 'errors/socket_error', layout: false
    rescue StandardError => e
      puts "----- Error occurred: #{e.message}"
      @error_message = "#{l(:text_exception_name)}: #{e.message}"
      render 'errors/error', layout: false
    end
  
  end

  def view_issue_test_results
    issue_id = params[:issue_id]
    issue = Issue.find(issue_id)
    
    # Check if the user is authorized to view the plugin.
    unless User.current.allowed_to?(:view_issue_test_results, issue.project)
      # The user is not authorized to view the plugin.
      Rails.logger.info(">>> #{User.current.login} does not have permission to view the Issue Edit for Kiwi Tests field, so this tab will not be created... !!!! <<<<")
      @error_message = "Kullanıcının bu bilgiye erişme yetkisi yok!"
      html_content = render_to_string(
        template: "errors/401",
        layout: false,
      )
      return render html: html_content
    end

    tests = Test
      .joins(:issue_tests)
      .where(issue_tests: { issue_id: issue_id })
      .select(:test_case_id, :summary)

    #commit_with_artifacst = UlakTest::Git.commit_tags(issue.changesets)
    commit_with_artifacst = UlakTest::Git.findTagsOfCommits(issue.changesets)

    html_content = render_to_string(
      template: "templates/_tab_content_issue_test_results.html.erb",
      # layout: false ile tüm Redmine sayfasının derlenMEmesini sağlarız
      layout: false,
      locals: {
        commit_with_artifacst: commit_with_artifacst,
        issue: issue,
        issue_id: issue_id,
        tests: tests,
      },
    )
    render html: html_content
  end
end
