module YodleeApi
  module Config
    # Global config.
    attr_accessor :application_id, :endpoint, :cobrand_login, :cobrand_password, :cobrand_id
    attr_writer :tnc_version
        
    # returns the terms and conditions statement version
    def tnc_version
      @tnc_version || 1
    end
    
    # returns the locale hash
    def locale
      @locale || { :country => "US", :language => "en", :variant => nil }
    end
    
    # sets the locale hash
    def locale=(loc)
      expected_keys = [:country, :language, :variant]
      begin
        loc.keys.each do |k|
          raise ArgumentError, "Invalid locale parameter: #{k}" unless expected_keys.include? k
        end
      rescue => e
        raise e, e.message
      else
        @locale = { :country => loc[:country] || locale[:country], 
                  :language => loc[:language] || locale[:language], 
                  :variant => loc[:variant] || locale[:variant]
                  }
      end
    end
          
  end
end


