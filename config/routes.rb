# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get "my_plugin/tests", to: "issue_test#get_tests"
get "/settings/plugin/my_plugin/tests/sync", to: "kiwi_api#sync_kiwi_test_cases"
get "/my_plugin/tests/sync", to: "kiwi_api#sync_kiwi_test_cases"
get "my_plugin/issues/:issue_id/tab/test_results", to: "issue_test#view_issue_test_results"
get "my_plugin/issues/:issue_id/tests/", to: "issue_test#get_issue_tests"
post "my_plugin/issues/:issue_id/tests/:test_id", to: "issue_test#add_test_to_issue"
delete "my_plugin/issues/:issue_id/tests/:test_id", to: "issue_test#remove_test_from_issue"
get "my_plugin/:issue_id", to: "my_plugin#index"
