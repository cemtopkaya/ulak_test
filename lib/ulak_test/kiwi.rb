module UlakTest
  module Kiwi
    @headers = {
      # "Cookie" => cookie, # Cookie bilgisi
      "Content-Type" => "application/json", # İstenilen gövde türü
    }

    def self.create_http(_url)
      url = URI.parse(_url)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true # Eğer HTTPS kullanılıyorsa bu satırı eklemeliyiz
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http
    end

    def self.get_rest_info
      rest_api_url = Setting.plugin_ulak_test["rest_api_url"]
      rest_api_username = Setting.plugin_ulak_test["rest_api_username"]
      rest_api_password = Setting.plugin_ulak_test["rest_api_password"]

      if rest_api_url.blank? || rest_api_username.blank? || rest_api_password.blank?
        Rails.logger.warn("--- Error: REST INFO can't be retrieved...")
        return nil
      end

      {
        url: rest_api_url,
        username: rest_api_username,
        password: rest_api_password,
      }
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
        response = http.post(url, body.to_json, @headers)
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
        url = rest.fetch(:url)
        http = create_http(url)

        # POST isteği yapma
        response = http.post(url, body.to_json, @headers)
        puts ">>>> Cevap istisnasız geldi: #{response}"
      rescue StandardError => e
        puts "----- Error occurred: #{e.message}"
      end
    end

    def self.fetch_kiwi_product(id = 3)
      login()
      result = nil

      begin
        rest = get_rest_info()
        body = make_request_body("Product.filter", [{ "id": id }])

        # HTTP isteği oluşturma
        url = rest.fetch(:url)
        http = create_http(url)

        # POST isteği yapma
        response = http.post(url, body.to_json, @headers)
        result = JSON.parse(response.body)["result"]
      rescue StandardError => e
        puts "----- Error occurred: #{e.message}"
      ensure
        logout()
      end
      result
    end

    def self.fetch_kiwi_products()
      login()
      result = nil

      begin
        rest = get_rest_info()
        body = make_request_body("Product.filter", [])

        # HTTP isteği oluşturma
        url = rest.fetch(:url)
        http = create_http(url)

        # POST isteği yapma
        response = http.post(url, body.to_json, @headers)
        if response.is_a?(Net::HTTPSuccess)
          puts "İstek başarılı. Yanıt: #{response.body}"
          result = JSON.parse(response.body)["result"]
        else
          puts "İstek başarısız. Hata kodu: #{response.code}, Hata mesajı: #{response.message}"
        end
      rescue StandardError => e
        puts "----- Error occurred: #{e.message}"
      ensure
        logout()
      end

      result
    end

    def self.fetch_kiwi_product_categories(product_id = 3)
      login()
      result = nil

      begin
        rest = get_rest_info()
        body = make_request_body("Category.filter", [{ product: product_id }])

        # HTTP isteği oluşturma
        url = rest.fetch(:url)
        http = create_http(url)

        # POST isteği yapma
        response = http.post(url, body.to_json, @headers)
        result = JSON.parse(response.body)["result"]
      rescue StandardError => e
        puts "----- Error occurred: #{e.message}"
      ensure
        logout()
      end

      result
    end

    def self.fetch_kiwi_test_cases(category_product = "3")
      login()
      result = nil

      begin
        rest = get_rest_info()
        body = make_request_body("TestCase.filter", [{ :category__product => category_product }])

        # HTTP isteği oluşturma
        url = rest.fetch(:url)
        http = create_http(url)

        # POST isteği yapma
        response = http.post(url, body.to_json, @headers)
        result = JSON.parse(response.body)["result"]
      rescue StandardError => e
        puts "----- Error occurred: #{e.message}"
      ensure
        logout()
      end

      result
    end

    def self.fetch_testexecution_by_case_id_in(case_ids)
      # parametre türünü belirtme
      # @param [Array] case_ids
      unless case_ids.is_a?(Array)
        raise ArgumentError, "case_ids parameter must be an array"
      end

      result = nil
      login()

      begin
        rest = get_rest_info()
        body = make_request_body("TestExecution.filter", [{ :case__id__in => case_ids }])
        # HTTP isteği oluşturma
        url = rest.fetch(:url)
        http = create_http(url)

        # POST isteği yapma
        response = http.post(url, body.to_json, @headers)
        result = JSON.parse(response.body)["result"]
      rescue StandardError => e
        puts "----- Error occurred: #{e.message}"
      ensure
        logout()
      end

      result
    end

    # ID değerleri verilen test durumlarının (test case) koşturulduğu
    # ve sonuçlarında koşunun durumunu dönecek fonksiyon.

    # @param [Array<Integer>] case_ids Test durumu kimlik numaralarının bir dizisi
    # @return [Array] Test sürdürmelerinin bir dizisi
    def self.fetch_testexecution_by_case_id_in(case_ids)
      unless case_ids.is_a?(Array)
        raise ArgumentError, "case_ids parameter must be an array"
      end

      result = nil
      login()

      begin
        rest = get_rest_info()
        body = make_request_body("TestExecution.filter", [{ :case__id__in => case_ids }])
        # HTTP isteği oluşturma
        url = rest.fetch(:url)
        http = create_http(url)

        # POST isteği yapma
        response = http.post(url, body.to_json, @headers)
        result = JSON.parse(response.body)["result"]
        result
      rescue StandardError => e
        puts "----- Error occurred: #{e.message}"
      ensure
        logout()
      end

      result
    end

    # Case ID değerleri için yapılan testler

    # @param [Array<Integer>] case_ids Test durumu kimlik numaralarının bir dizisi
    # @return [Array] Test sürdürmelerinin bir dizisi
    def self.fetch_run_by_case_id_in(run_ids)
      unless run_ids.is_a?(Array)
        raise ArgumentError, "run_ids parameter must be an array"
      end

      result = nil
      login()

      begin
        rest = get_rest_info()
        body = make_request_body("TestRun.filter", [{ :id__in => run_ids }])

        # HTTP isteği oluşturma
        url = rest.fetch(:url)
        http = create_http(url)

        # POST isteği yapma
        response = http.post(url, body.to_json, @headers)
        result = JSON.parse(response.body)["result"]
      rescue StandardError => e
        puts "----- Error occurred: #{e.message}"
      ensure
        logout()
      end

      result
    end
  end
end
