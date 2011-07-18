module YodleeApi
  class CobrandCredentials 
    attr_writer :cobrand_id, :application_id, :cobrand_login, :cobrand_password, :tnc_version
    Credentials = [:cobrand_id, :application_id, :cobrand_login, :cobrand_password, :tnc_version, :locale]
    
    def initialize args = {}
      args.each do |k,v|
        raise ArgumentError, "Invalid Credential specified: #{k}" unless Credentials.include? k
        if k == :locale
          expected_keys = [:country, :language, :variant]
          begin
            v.keys.each do |k|
              raise ArgumentError, "Invalid locale parameter: #{k}" unless expected_keys.include? k
            end
          rescue => e
            raise e, e.message
          else
            @locale = { :country => v[:country] || YodleeApi.locale[:country], 
                        :language => v[:language] || YodleeApi.locale[:language], 
                        :variant => v[:variant]   || YodleeApi.locale[:variant] 
                      }
          end
        else
          instance_variable_set("@#{k}", v) unless v.nil?
        end
      end
    end
    
    # gets the locale, defaults to global locale
    def locale
      @locale || YodleeApi.locale
    end
    
    # sets the locale
    def locale=(loc)
        expected_keys = [:country, :language, :variant]
        begin
          loc.keys.each do |k|
            raise ArgumentError, "Invalid locale parameter: #{k}" unless expected_keys.include? k
          end
        rescue => e
          raise e, e.message
        else
          @locale = { :country => loc[:country] || YodleeApi.locale[:country], 
                      :language => loc[:language] || YodleeApi.locale[:language], 
                      :variant => loc[:variant] || YodleeApi.locale[:variant] 
                    }
        end
    end
    
    # gets the cobrand_id, defaults to global cobrand_id
    def cobrand_id
      @cobrand_id || YodleeApi.cobrand_id
    end  
    
    # gets the application_id, defaults to global application_id
    def application_id
      @application_id || YodleeApi.application_id
    end
    
    # gets the cobrand login, defaults to global cobrand_login
    def cobrand_login
      @cobrand_login || YodleeApi.cobrand_login
    end
    
    # gets the cobrand_password, defaults to global cobrand_password
    def cobrand_password
      @cobrand_password || YodleeApi.cobrand_password
    end
    
    def tnc_version
      @tnc_version || YodleeApi.tnc_version
    end
      
  end
end