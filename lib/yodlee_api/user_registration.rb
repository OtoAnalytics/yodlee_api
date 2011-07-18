module YodleeApi
  class UserRegistration
    
    attr_accessor :credentials, :soap_service
    attr_writer :endpoint
    attr_reader :client, :cobrand_context
    
    def endpoint
      @endpoint || YodleeApi.endpoint
    end
    
    
    def register
      @response = client.request :user, :register3 do
        soap.element_form_default = :unqualified     
        soap.namespaces["xmlns:login"] = 'http://login.ext.soap.yodlee.com'
        soap.namespaces["xmlns:common"] = "http://common.soap.yodlee.com"
                   
        soap.body = {
         :cobrand_context => cobrand_context,
         :user_credentials => credentials.credentials_hash, :attributes! => {:user_credentials => {"xsi:type" => "login:PasswordCredentials"}},
         :user_profile => credentials.profile_hash,       
         :order! => [:cobrand_context, :user_credentials, :user_profile] 
        }
      end
    end
    
    
    private
    
    def initialize(context, creds)
      @soap_service = "UserRegistrationService"
      @credentials = creds
      @cobrand_context = context

      @client = Savon::Client.new do
         wsdl.endpoint = File.join(endpoint, soap_service)
         wsdl.namespace = "http://userregistration.usermanagement.core.soap.yodlee.com"
      end
    end
        
  end
end


