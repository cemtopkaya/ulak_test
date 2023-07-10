class Test < ActiveRecord::Base
  has_many :issue_tests
  has_many :issues, through: :issue_tests
  has_and_belongs_to_many :issues
end
