class JenkinsScriptlerApiController < ApplicationController
  def get_environments
    @headers = {
      # "Cookie" => cookie, # Cookie bilgisi
      "Content-Type" => "application/json", # İstenilen gövde türü
      "Authorization" => "Basic Y2VtLnRvcGtheWE6MTEwYjAzM2JmZjZhNGJlZDY0MWFiNzZmYTZmMzcwNDg5Ng==",
      "Cookie" => "JSESSIONID.e1d859f8=node0xhqg54lwzxgy4hd48ko5fms3478.node0",
    }

    arch = params[:ARCH]
    target_servers = JenkinsScriptlerApiController.get_environments_by_arch(arch)

    render json: { result: target_servers }, status: :ok
  end

  def self.get_environments_by_arch(arch)
    url = "https://jenkins-5gcn.ulakhaberlesme.com.tr/scriptler/run/servers.groovy?ARCH=#{arch}"

    # Kullanıcı adı ve token değerini değişkenlere atayın
    kullanici_adi = "cem.topkaya"
    token = "110b033bff6a4bed641ab76fa6f3704896"

    # Basic Authentication kimlik doğrulama başlığını oluşturun
    auth_basligi = "Basic " + Base64.strict_encode64("#{kullanici_adi}:#{token}")

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
