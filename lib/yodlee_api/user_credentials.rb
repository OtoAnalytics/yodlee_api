module YodleeApi
  class UserCredentials
    attr_accessor :login_name, :password, :email
    
    # returns credentials hash
    def credentials_hash
      { 
        :login_name => login_name, 
        :password => password, 
        :attributes! => {:login_name => {"xsi:type" => "xsd:string"}, :password => {"xsi:type" => "xsd:string"}},
        :order! => [:login_name, :password] 
      }
    end
    
    # returns profile hash
    def profile_hash
      { :values => 
        { 
          :table => {
            :key => 'EMAIL_ADDRESS', 
            :value => email, 
            :attributes! => {:key => {"xsi:type" => "xsd:string"}, :value => {"xsi:type" => "xsd:string"}},
            :order! => [:key, :value]} 
        } 
      }
    end
    
    private
    
    Credentials = [:login_name, :password, :email]
    
    def initialize args
      args.each do |k,v|
        raise ArgumentError, "Invalid Credential specified: #{k}" unless Credentials.include? k
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end
    
    
  end
end

