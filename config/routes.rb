# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get "ulak_test/tests", to: "issue_test#get_tests"
get "/settings/plugin/ulak_test/tests/sync", to: "kiwi_api#sync_kiwi_test_cases"
get "/ulak_test/tests/sync", to: "kiwi_api#sync_kiwi_test_cases"
get "ulak_test/issues/:issue_id/tab/code_artifacts", to: "issue_code_artifacts#view_issue_code_artifacts"
get "ulak_test/issues/:issue_id/tab/test_results", to: "issue_test#view_issue_test_results"
get "ulak_test/issues/:issue_id/tests/", to: "issue_test#get_issue_tests"
post "ulak_test/issues/:issue_id/tests/:test_id", to: "issue_test#add_test_to_issue"
delete "ulak_test/issues/:issue_id/tests/:test_id", to: "issue_test#remove_test_from_issue"
get "ulak_test/environments", to: "jenkins_scriptler_api#get_environments"
get "ulak_test/:issue_id", to: "ulak_test#index"
