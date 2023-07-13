class KiwiApiController < ApplicationController
  def sync_kiwi_test_cases
    all_tests_before = Test.all
    products = UlakTest::Kiwi.fetch_kiwi_products()
    products.each do |product|
      cases = UlakTest::Kiwi.fetch_kiwi_test_cases(product["id"])
      Rails.logger.info(">>> cases: #{cases}")
      cases.each do |c|
        test = Test.find_or_create_by({ test_case_id: c["id"], summary: c["summary"], product_id: product["id"], category: c["category"], category_name: c["category__name"] })
        puts "test: #{test}"
      end
    end
    all_tests_after = Test.all

    render json: {
      before: all_tests_before.count,
      after: all_tests_after.count,
    }, status: :ok
  end
end
