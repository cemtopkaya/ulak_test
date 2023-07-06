require "net/http"
require "uri"
require "json"
require "openssl"

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

module MyPlugin
  module Hooks
    class IssueTestsTab < Redmine::Hook::ViewListener
      def view_issues_show_description_bottom(context = {})
        issue_id = context[:request].params[:id]
        tests = Test.joins(:issue_tests).where(issue_tests: { issue_id: issue_id }).select(:id, :test_name)
        formatted_tests = tests.map { |test| { id: test.id, text: test.test_name } }
        issue_data = { issue_id: issue_id, issue_tests: formatted_tests }.to_json

        hook_caller = context[:hook_caller]
        # If the hook was triggered by a controller action, then `hook_caller` will be the controller instance.
        if hook_caller.is_a?(ActionController::Base)
          Rails.logger.info(">>>> hook_caller: #{hook_caller}")
          controller = hook_caller
        else
          # If the hook was triggered by something else, then `hook_caller` will be the object that triggered the hook.
          Rails.logger.info(">>>> controller: #{hook_caller.is_a?(ActionController::Base)}")
          controller = hook_caller.controller
        end
        output = controller.send(:render_to_string, {
          partial: "issues/tabs/issue_tests",
          locals: { issueData: issue_data },
        })
        Rails.logger.info(">>>>> return: #{output}")
        output.html_safe
      end

      def self.make_post_request(url = "https://kiwi.ulakhaberlesme.com.tr/json-rpc/", body = { :jsonrpc => "2.0", :method => "TestCase.filter", :params => [{ :category__product => "3" }], :id => "jsonrpc" })
        cookie = "ajs_user_id=da089f0e-762d-588f-b352-36da613ad1e0; ajs_anonymous_id=4638ae52-b224-44bc-b945-7cf517568e44; csrftoken=axEYH93rf6CjmdhrxKdVoazNeQJUECs2; sessionid=zv8lulm4agcuwvxg9ub9tj8isq966uay"

        headers = {
          "Cookie" => cookie, # Cookie bilgisi
          "Content-Type" => "application/json", # İstenilen gövde türü
        }

        # HTTP isteği oluşturma
        url = URI.parse(url)
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true # Eğer HTTPS kullanılıyorsa bu satırı eklemeliyiz
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        # POST isteği yapma
        response = http.post(url.path, body.to_json, headers)

        # Yanıtı alıp işleme
        if response.is_a?(Net::HTTPSuccess)
          puts "İstek başarılı. Yanıt: #{response.body}"
        else
          puts "İstek başarısız. Hata kodu: #{response.code}, Hata mesajı: #{response.message}"
        end
        return response
      end

      def self.sync_kiwi_tests
        unless Setting.my_plugin["rest_api_url"].blank? && Setting.my_plugin["rest_api_username"].blank? && Setting.my_plugin["rest_api_password"].blank?
          rest_api_url = Setting.my_plugin["rest_api_url"]
          rest_api_username = Setting.my_plugin["rest_api_username"]
          rest_api_password = Setting.my_plugin["rest_api_password"]
          login_body = { :jsonrpc => "2.0",
                        :method => "Auth.login",
                        :id => "jsonrpc",
                        :params => {
            :username => rest_api_username,
            :password => rest_api_password,
          } }
          make_post_request(rest_api_url, login_body.to_json)
          puts "oldu"
        end
        puts "olmadı"
      end

      def self.get_tests
        begin
          response = make_post_request()
          result = JSON.parse(response.body)["result"]
          return result.map { |item| { id: item["id"], summary: item["summary"] } }
        rescue StandardError => e
          puts "Error occurred: #{e.message}"
        end
        # result = parsed_json['result'].map { |item| { 'id' => item['id'], 'summary' => item['summary'] } }

      end
    end
  end
end
