module YodleeApi
  
  # A service interface that handles Item management in the Yodlee 5 platform. This interface allows users to
  # add new Member Items, edit the authentication credentials and delete existing Member Items from the system.
  # The interface also supports methods to retrieve the fields required for adding a particular ContentService.
  # 2931
  class ItemManagement
    
    attr_accessor :soap_service
    attr_writer :endpoint
    attr_reader :client
  
    # gets the endpoint, defaults to globally defined endpoint
    def endpoint
      @endpoint || YodleeApi.endpoint
    end

    # returns a deep copy of the user context, this will only be available after successful registration
    def cobrand_context
      YodleeApi.deep_copy(@cobrand_context)
    end
    
    # Return all the credential fields that are required for adding a Member Item corresponding to the 
    # ContentService specified by the contentServiceId. It returns null if the ContentService is shared. eg:news
    def get_login_form(cs_id)
      @response = client.request :item, :get_login_form_for_content_service do
        soap.element_form_default = :unqualified     
        soap.namespaces["xmlns:login"] = 'http://login.ext.soap.yodlee.com'
                   
        soap.body = {
         :cobrand_context => cobrand_context,
         :content_service_id => cs_id
        }
        
      end
      
      hash_response = @response.to_hash
      
    end
    
    private
    
    def initialize(ctxt)
      @cobrand_context = ctxt   
      @soap_service = "ItemManagementService"

      @client = Savon::Client.new do
         http.auth.ssl.verify_mode = :none              
         wsdl.endpoint = File.join(endpoint, soap_service)
         wsdl.namespace = "http://userregistration.usermanagement.core.soap.yodlee.com"
      end   
    end
    
  end
end