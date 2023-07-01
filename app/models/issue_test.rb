class IssueTest < ActiveRecord::Base
    belongs_to :issue
    belongs_to :test
end
  