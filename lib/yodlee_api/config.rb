module YodleeApi
  module Config
    # Global config.
    attr_accessor :application_id, :endpoint, :cobrand_login, :cobrand_password, :cobrand_id
    attr_writer :tnc_version, :locale
    
    # returns the terms and conditions statement version
    def tnc_version
      @tnc_version || 1
    end
    
    # returns the locale hash
    def locale
      @locale || { :country => "US", :language => "en", :variant => nil, :order! => [:country, :language, :variant] }
    end
          
  end
end


