# 20230627140000_create_tests_and_issue_tests_tables.rb

class CreateTestsAndIssueTestsTables < ActiveRecord::Migration[5.2]
  def change
    puts "Running migration: CreateTestsAndIssueTestsTables"

    create_table :tests do |t|
      t.integer :test_case_id, index: true
      t.string :summary
      t.integer :category
      t.string :category_name
      t.integer :product_id
      t.timestamps
    end

    create_table :issue_tests do |t|
      t.references :issue, index: true
      t.references :test, index: true
      t.timestamps
    end
  end
end
