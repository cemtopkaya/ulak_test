# 20230627140000_create_tests_and_issue_tests_tables.rb

class CreateTestsAndIssueTestsTables < ActiveRecord::Migration[5.2]
  def change
    puts "Running migration: CreateTestsAndIssueTestsTables"

    create_table :tests do |t|
      t.string :test_name
      t.integer :product_id
      t.timestamp :create_date
      t.timestamp :last_retrieve_date
      t.timestamps
    end

    create_table :issue_tests do |t|
      t.references :issue, index: true
      t.references :test, index: true
      t.timestamps
    end
  end
end
