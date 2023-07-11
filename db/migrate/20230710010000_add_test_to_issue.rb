class AddTestToIssue < ActiveRecord::Migration[5.2]
    def change
      add_reference :issues, :test, index: true
    end
  end
  