module MyPlugin
  module Kiwi
    @headers = {
      # "Cookie" => cookie, # Cookie bilgisi
      "Content-Type" => "application/json", # İstenilen gövde türü
    }

    def self.get_rest_info
      unless Setting.plugin_my_plugin["rest_api_url"].blank? && Setting.plugin_my_plugin["rest_api_username"].blank? && Setting.plugin_my_plugin["rest_api_password"].blank?
        url = Setting.plugin_my_plugin["rest_api_url"]
        username = Setting.plugin_my_plugin["rest_api_username"]
        password = Setting.plugin_my_plugin["rest_api_password"]
        return {
                 :url => url,
                 :username => username,
                 :password => password,
               }
      else
        Rails.logger.warning("--- Error: REST INFO can't be retrieved...")
      end
    end

    def self.get_rest_info
      url = Setting.plugin_my_plugin["rest_api_url"]
      username = Setting.plugin_my_plugin["rest_api_username"]
      password = Setting.plugin_my_plugin["rest_api_password"]

      if url.present? && username.present? && password.present?
        {
          :url => url,
          :username => username,
          :password => password,
        }
      else
        Rails.logger.warn("--- Error: REST INFO can't be retrieved...")
        nil
      end
    end

    def self.make_request_body(method = nil, params = {})
      body = {
        jsonrpc: "2.0",
        method: method,
        id: "jsonrpc",
      }

      body = body.merge({ :params => params }) unless params.empty?

      body
    end

    def self.login
      begin
        @headers.delete(:Cookie)
        rest = get_rest_info()
        body = make_request_body("Auth.login", {
          :username => rest.fetch(:username),
          :password => rest.fetch(:password),
        })

        # HTTP isteği oluşturma
        url = URI.parse(rest.fetch(:url))
        http = Net::HTTP.new(url.host, url.port)
        http.set_debug_output($stdout)
        http.use_ssl = true # Eğer HTTPS kullanılıyorsa bu satırı eklemeliyiz
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        # POST isteği yapma
        response = http.post(url.path, body.to_json, @headers)
        # Yanıtı alıp işleme
        if response.is_a?(Net::HTTPSuccess)
          puts "İstek başarılı. Yanıt: #{response.body}"
        else
          puts "İstek başarısız. Hata kodu: #{response.code}, Hata mesajı: #{response.message}"
        end
      rescue StandardError => e
        puts "----- Error occurred: #{e.message}"
      end
      @headers[:Cookie] = "sessionid=#{JSON.parse(response.body)["result"]}"
      JSON.parse(response.body)["result"]
    end

    def self.logout
      begin
        rest = get_rest_info()
        body = make_request_body("TestCase.filter", [{ :category__product => "3" }])

        # HTTP isteği oluşturma
        url = URI.parse(rest.fetch(:url))
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true # Eğer HTTPS kullanılıyorsa bu satırı eklemeliyiz
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        # POST isteği yapma
        response = http.post(url.path, body.to_json, @headers)
        puts ">>>> Cevap istisnasız geldi: #{response}"
      rescue StandardError => e
        puts "----- Error occurred: #{e.message}"
      end
    end

    def self.fetch_kiwi_product(id = 3)
      login()

      begin
        rest = get_rest_info()
        body = make_request_body("Product.filter", [{ "id": id }])

        # HTTP isteği oluşturma
        url = URI.parse(rest.fetch(:url))
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true # Eğer HTTPS kullanılıyorsa bu satırı eklemeliyiz
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        # POST isteği yapma
        response = http.post(url.path, body.to_json, @headers)
        result = JSON.parse(response.body)["result"]
        result
      rescue StandardError => e
        puts "----- Error occurred: #{e.message}"
      end

      logout()
    end

    def self.fetch_kiwi_products()
      login()

      begin
        rest = get_rest_info()
        body = make_request_body("Product.filter", [])

        # HTTP isteği oluşturma
        url = URI.parse(rest.fetch(:url))
        http = Net::HTTP.new(url.host, url.port)
        http.set_debug_output($stdout)
        http.use_ssl = true # Eğer HTTPS kullanılıyorsa bu satırı eklemeliyiz
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        # POST isteği yapma
        response = http.post(url.path, body.to_json, @headers)
        if response.is_a?(Net::HTTPSuccess)
          puts "İstek başarılı. Yanıt: #{response.body}"
          result = JSON.parse(response.body)["result"]
        else
          puts "İstek başarısız. Hata kodu: #{response.code}, Hata mesajı: #{response.message}"
        end
      rescue StandardError => e
        puts "----- Error occurred: #{e.message}"
      end

      logout()

      result
    end

    def self.fetch_kiwi_product_categories(product_id = 3)
      login()

      begin
        rest = get_rest_info()
        body = make_request_body("Category.filter", [{ product: product_id }])

        # HTTP isteği oluşturma
        url = URI.parse(rest.fetch(:url))
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true # Eğer HTTPS kullanılıyorsa bu satırı eklemeliyiz
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        # POST isteği yapma
        response = http.post(url.path, body.to_json, @headers)
        result = JSON.parse(response.body)["result"]
        result
      rescue StandardError => e
        puts "----- Error occurred: #{e.message}"
      end

      logout()
    end

    def self.fetch_kiwi_test_cases(category_product = "3")
      login()

      begin
        rest = get_rest_info()
        body = make_request_body("TestCase.filter", [{ :category__product => category_product }])

        # HTTP isteği oluşturma
        url = URI.parse(rest.fetch(:url))
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true # Eğer HTTPS kullanılıyorsa bu satırı eklemeliyiz
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        # POST isteği yapma
        response = http.post(url.path, body.to_json, @headers)
        result = JSON.parse(response.body)["result"]
      rescue StandardError => e
        puts "----- Error occurred: #{e.message}"
      end

      logout()
      result
    end
  end
end
