# credential_fields = [
#   YodleeApi::CredentialFields.new(:name => "LOGIN", :display_name => "Online ID",  :is_editable => true, :is_optional => false, :is_escaped => false, :is_optional_mfa => false, 
#       :is_mfa => false, :value => "kariukigrass", :value_identifier => "LOGIN", :value_mask => "LOGIN_FIELD", :field_type => "TEXT", :size => 20, :max_length => 40),
#   YodleeApi::CredentialFields.new(:name => "PASSWORD", :display_name => "Passcode",  :is_editable => true, :is_optional => false, :is_escaped => false, :is_optional_mfa => false, 
#       :is_mfa => false, :value => "testing1", :value_identifier => "PASSWORD", :value_mask => "LOGIN_FIELD", :field_type => "PASSWORD", :size => 20, :max_length => 20),
#   YodleeApi::CredentialFields.new(:name => nil, :display_name => "Verify Passcode",  :is_editable => true, :is_optional => false, :is_escaped => false, :is_optional_mfa => false, 
#       :is_mfa => false, :value => "testing1", :value_identifier => "LOGIN", :value_mask => "LOGIN_FIELD", :field_type => "PASSWORD", :size => 20, :max_length => 20)
# ]
# 



module YodleeApi
  
  class CredentialFields
        
    attr_accessor :name, :display_name, :is_editable, :is_optional, :is_escaped, :is_optional_mfa, :is_mfa, :value, :value_identifier, :value_mask, :field_type, :size, :max_length
    
    def field_hash
      {
        :name => name,
        :display_name => display_name, 
        :is_editable => is_editable, 
        :is_optional => is_optional, 
        :is_escaped => is_escaped, 
        "isOptionalMFA" => is_optional_mfa, 
        "isMFA" => is_mfa, 
        :value => value, 
        :value_identifier => value_identifier, 
        :value_mask => value_mask,
        :field_type => field_type, 
        :size => size, 
        :maxlength => max_length
      }
    end
    
    private
                      
    Attributes = [:name, :display_name, :is_editable, :is_optional, :is_escaped, :is_optional_mfa, :is_mfa, :value, :value_identifier, :value_mask, :field_type, :size, :max_length]
    
    def initialize args
      args.each do |k,v|
        raise ArgumentError, "Invalid attribute specified: #{k}" unless Attributes.include? k
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end
          
  end
  
  class UserCredentials
    attr_accessor :login_name, :password, :email
    
    # returns credentials hash
    def credentials_hash
      YodleeApi.deep_copy({ 
        :login_name => login_name, 
        :password => password, 
        :attributes! => {:login_name => {"xsi:type" => "xsd:string"}, :password => {"xsi:type" => "xsd:string"} }
      })
    end
    
    # returns profile hash
    def profile_hash
      { :values => 
        { 
          :table => {
            :key => 'EMAIL_ADDRESS', 
            :value => email, 
            :attributes! => { 
              :key => {"xsi:type" => "xsd:string"}, 
              :value => {"xsi:type" => "xsd:string"} 
            }
          } 
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

