Rails.application.routes.draw do
    # Diğer rotalar burada
  
    # Kiwi API rotaları
    get "#{$NAME_KIWI_TESTS}/tests", to: "issue_test#get_tests"
    get "#{$NAME_KIWI_TESTS}/tests/sync", to: "kiwi_api#sync_kiwi_test_cases"
  
    # Issue Test rotaları
    get "#{$NAME_KIWI_TESTS}/issues/:issue_id/tab/test_results", to: "issue_test#view_issue_test_results"
    get "#{$NAME_KIWI_TESTS}/issues/:issue_id/tab/test_results/changesets/:changeset_id/tags", to: "issue_test#view_tag_runs"
    get "#{$NAME_KIWI_TESTS}/issues/:issue_id/tests/", to: "issue_test#get_issue_tests"
    post "#{$NAME_KIWI_TESTS}/issues/:issue_id/tests/:test_id", to: "issue_test#add_test_to_issue"
    delete "#{$NAME_KIWI_TESTS}/issues/:issue_id/tests/:test_id", to: "issue_test#remove_test_from_issue"
  end
  