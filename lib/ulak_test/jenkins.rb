module UlakTest
  module Jenkins
    def self.get_jenkins_settings
      jenkins_url = Setting.plugin_ulak_test["jenkins_url"]
      jenkins_username = Setting.plugin_ulak_test["jenkins_username"]
      jenkins_token = Setting.plugin_ulak_test["jenkins_token"]

      if jenkins_url.blank? || jenkins_username.blank? || jenkins_token.blank?
        Rails.logger.warn("--- Error: JENKINS INFO can't be retrieved...")
        return nil
      end

      {
        url: jenkins_url,
        username: jenkins_username,
        token: jenkins_token,
      }
    end
    
  def self.get_environments_by_arch(arch)
    jenkins = UlakTest::Jenkins.get_jenkins_settings
    url = "#{jenkins[:url]}/scriptler/run/servers.groovy?ARCH=#{arch}"

    # Kullanıcı adı ve token değerini değişkenlere atayın
    # Basic Authentication kimlik doğrulama başlığını oluşturun
    auth_basligi = "Basic " + Base64.strict_encode64("#{jenkins[:username]}:#{jenkins[:token]}")

    begin
      # HTTP isteği oluşturma
      url = URI.parse(url)
      http = Net::HTTP.new(url.host, url.port)
      http.set_debug_output($stdout)
      http.use_ssl = true # Eğer HTTPS kullanılıyorsa bu satırı eklemeliyiz
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      # İstek yaparken kimlik doğrulama başlığını ekleyin
      headers = { "Authorization" => auth_basligi }

      # POST isteği yap
      response = http.post(url, nil, headers)

      # Yanıtı alıp işleme
      if response.is_a?(Net::HTTPSuccess)
        puts "İstek başarılı. Yanıt: #{response.body}"
        target_servers = self.convert_groovy_result_to_json(response.body)

        puts target_servers.inspect
        return target_servers
      else
        puts "---- İstek başarısız. Hata kodu: #{response.code}, Hata mesajı: #{response.message}"
      end
    rescue StandardError => e
      puts "----- Error occurred: #{e.message}"
    end
  end

  private

  def self.convert_groovy_result_to_json(result)
    text = result.sub!("Result:   ", "")
    obj = JSON.parse(text)
    obj
  end
  end
end
