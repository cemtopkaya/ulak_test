module UlakTest
    module PluginSetting


        @kiwi_settings = nil

        def self.get_kiwi_settings
      
            # Eğer sonuç ön bellekte varsa, direkt olarak onu döndür.
            return @kiwi_settings if @kiwi_settings
      
            kiwi_url = Setting[$PLUGIN_NAME_KIWI_TESTS]["kiwi_url"]
            rest_api_url = Setting[$PLUGIN_NAME_KIWI_TESTS]["rest_api_url"]
            rest_api_username = Setting[$PLUGIN_NAME_KIWI_TESTS]["rest_api_username"]
            rest_api_password = Setting[$PLUGIN_NAME_KIWI_TESTS]["rest_api_password"]
      
            if rest_api_url.blank? || rest_api_username.blank? || rest_api_password.blank?
              Rails.logger.warn("--- Error: REST INFO can't be retrieved...")
              return nil
            end
      
            @kiwi_settings = {
              kiwi_url: kiwi_url,
              url: rest_api_url,
              username: rest_api_username,
              password: rest_api_password,
            }
          end

          def self.apply_new_settings
            @kiwi_settings = nil
          end
    end
end