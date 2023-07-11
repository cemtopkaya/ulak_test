class Issue < ActiveRecord::Base
  has_many :issue_tests
  has_many :tests, through: :issue_tests
end
