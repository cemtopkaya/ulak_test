module UlakTest
  module Kiwi

# Test senaryolarının durumları
# "BOŞTA"        : 1
# "KOŞUYOR"      : 2 
# "DURAKLATILDI" : 3
# "GEÇTİ"        : 4
# "BAŞARISIZ"    : 5
# "BLOKE"        : 6
# "HATALI"       : 7
# "VAZGEÇİLDİ"   : 8

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

    def self.is_kiwi_accessable
      begin
        login()
        return {
          is_accessable: true,
          message: "Kiwi server is accessable"
        }
      rescue StandardError => e
        puts "----- Error occurred: #{e.message}"
        raise e
        return {
          is_accessable: false,
          message: "Kiwi server is not accessable! Error:  #{e.message}"
        }
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
        rest = UlakTest::PluginSetting.get_kiwi_settings()
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
        raise e
      end
      @headers[:Cookie] = "sessionid=#{JSON.parse(response.body)["result"]}"
      JSON.parse(response.body)["result"]
    end

    def self.logout
      begin
        rest = UlakTest::PluginSetting.get_kiwi_settings()
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
        rest = UlakTest::PluginSetting.get_kiwi_settings()
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
        rest = UlakTest::PluginSetting.get_kiwi_settings()
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
        rest = UlakTest::PluginSetting.get_kiwi_settings()
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
        rest = UlakTest::PluginSetting.get_kiwi_settings()
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
        rest = UlakTest::PluginSetting.get_kiwi_settings()
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

    # ID değerleri verilen test durumlarının (test case) koşturulduğu
    # ve sonuçlarında koşunun durumunu dönecek fonksiyon.

    # @param [Array<Integer>] case_ids Test durumu kimlik numaralarının bir dizisi
    # @return [Array] Test sürdürmelerinin bir dizisi
    def self.fetch_testexecution_by_run_id_in_case_id_in(run_ids, case_ids)
      unless run_ids.is_a?(Array)
        raise ArgumentError, "run_ids parameter must be an array"
      end

      unless case_ids.is_a?(Array)
        raise ArgumentError, "case_ids parameter must be an array"
      end

      result = nil
      login()

      begin
        rest = UlakTest::PluginSetting.get_kiwi_settings()
        body = make_request_body("TestExecution.filter", [{ :case__id__in => case_ids, :run__id__in => run_ids  }])
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

    # RUN ID değerleri içinde etiketleri arar

    # @param [Array<Integer>] Test koşumlarının ID değerlerini içeren dizi
    # @param [String] Etiket adı içerisinde paket_adı=versiyonu değeri gelecek
    # @return [String] ???
    def self.fetch_tags_by_run_ids(run_ids, tag_name)
      unless run_ids.is_a?(Array)
        raise ArgumentError, "run_ids parameter must be an array"
      end

      if tag_name.empty?
        raise ArgumentError, "tag_name parameter must be a string"
      end

      result = nil
      login()

      begin
        rest = UlakTest::PluginSetting.get_kiwi_settings()
        body = make_request_body("Tag.filter", [{ :run__id__in => run_ids, :name => tag_name }])
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

    # RUN ID değerleri içinde etiketleri arar

    # @param [String] tag_name ile etiket adı gelir
    # @param [String] Etiket adı içerisinde paket_adı=versiyonu değeri gelecek
    # @return [String]
    def self.fetch_tags_by_tag_name(tag_name)
      if tag_name.empty?
        raise ArgumentError, "tag_name parameter must be a string"
      end

      result = nil
      login()

      begin
        rest = UlakTest::PluginSetting.get_kiwi_settings()
        body = make_request_body("Tag.filter", [{ :name => tag_name }])
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


    # Case ID değerleri için yapılan testler

    # @param [Array<Integer>] case_ids Test durumu kimlik numaralarının bir dizisi
    # @return [Array] Test sürdürmelerinin bir dizisi
    def self.fetch_runs_by_id_in(run_ids)
      unless run_ids.is_a?(Array)
        raise ArgumentError, "run_ids parameter must be an array"
      end

      result = nil
      login()

      begin
        rest = UlakTest::PluginSetting.get_kiwi_settings()
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
