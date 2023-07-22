Rails.application.routes.draw do
    # Diğer rotalar burada
  
    # Kiwi API rotaları
    namespace :ulak_test do
      get "tests", to: "issue_test#get_tests"
      get "tests/sync", to: "kiwi_api#sync_kiwi_test_cases"
    end
  
    # Issue Test rotaları
    get "ulak_test/issues/:issue_id/tab/test_results", to: "issue_test#view_issue_test_results"
    get "/ulak_test/issues/:issue_id/tab/test_results/changesets/:changeset_id/tags", to: "issue_test#view_tag_runs"
    get "ulak_test/issues/:issue_id/tests/", to: "issue_test#get_issue_tests"
    post "ulak_test/issues/:issue_id/tests/:test_id", to: "issue_test#add_test_to_issue"
    delete "ulak_test/issues/:issue_id/tests/:test_id", to: "issue_test#remove_test_from_issue"
      
    # Jenkins Scriptler API rotası
    get "ulak_test/environments", to: "jenkins_scriptler_api#get_environments"
  
    # Ulak Test rotası
    get "ulak_test/:issue_id", to: "ulak_test#index"
  end
  