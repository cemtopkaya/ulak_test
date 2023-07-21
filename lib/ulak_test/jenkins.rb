module UlakTest
  module Jenkins
    
    @jenkins_settings = nil

    def self.get_jenkins_settings
      # Eğer sonuç ön bellekte varsa, direkt olarak onu döndür.
      return @jenkins_settings if @jenkins_settings
      
      jenkins_url = Setting[$PLUGIN_NAME]["jenkins_url"]
      jenkins_username = Setting[$PLUGIN_NAME]["jenkins_username"]
      jenkins_token = Setting[$PLUGIN_NAME]["jenkins_token"]
      deployment_job_path = Setting[$PLUGIN_NAME]["deployment_job_path"]
      deployment_job_token = Setting[$PLUGIN_NAME]["deployment_job_token"]

      if jenkins_url.blank? || jenkins_username.blank? || jenkins_token.blank?
        Rails.logger.warn("--- Error: JENKINS INFO can't be retrieved...")
        return nil
      end

      # Sonucu @jenkins_settings değişkeninde sakla ve döndür.
      @jenkins_settings = {
        url: jenkins_url,
        username: jenkins_username,
        token: jenkins_token,
        deployment_job_path: deployment_job_path,
        deployment_job_token: deployment_job_token,
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
