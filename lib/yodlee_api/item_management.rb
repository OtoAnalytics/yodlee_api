module YodleeApi
  
  # A service interface that handles Item management in the Yodlee 5 platform. This interface allows users to
  # add new Member Items, edit the authentication credentials and delete existing Member Items from the system.
  # The interface also supports methods to retrieve the fields required for adding a particular ContentService.
  # 2931
  class ItemManagement
    
    attr_accessor :soap_service
    attr_writer :endpoint
    attr_reader :client, :forms
  
    # gets the endpoint, defaults to globally defined endpoint
    def endpoint
      @endpoint || YodleeApi.endpoint
    end

    # returns a deep copy of the user context, this will only be available after successful registration
    def cobrand_context
      YodleeApi.deep_copy(@cobrand_context)
    end
    
    # Return A map keyed by specified content service IDs and values are credential fields that are required for 
    # adding a Member Item to the content service encapsulated in a Form object. Map Values will be null for shared ContentServices. 
    # eg:news It returns null if the ContentService is shared. eg:news
    def get_login_forms(cs_ids)
      @response = client.request :item, :get_login_forms_for_content_services do
        soap.element_form_default = :unqualified     
        soap.namespaces["xmlns:login"] = 'http://login.ext.soap.yodlee.com'
                   
        soap.body = {
         :cobrand_context => cobrand_context,
         :content_service_ids => {:elements => cs_ids}
        }
        
      end
      @forms = @response.to_xml
      # response_xml = @response.to_xml
      # parse_response(response_xml)      
    end
    
    private
    
    def initialize(ctxt)
      @cobrand_context = ctxt   
      @soap_service = "ItemManagementService"
      @forms = []

      @client = Savon::Client.new do
         http.auth.ssl.verify_mode = :none              
         wsdl.endpoint = File.join(endpoint, soap_service)
         wsdl.namespace = "http://itemmanagement.accountmanagement.core.soap.yodlee.com"
      end   
    end
    
    
    def parse_response
      doc = Nokogiri::XML(response_xml)
      tables = doc.search("table")
      
      tables.each do |form| 
        elements = form.search("elements").map { |field| field.children.map {|c| {c.name => c.text} } }          
      end
      
      @forms = doc.at("value").children.map {|c| {:content_service_id => c.elements[0].text, :site_name => c.elements[2].text}}
    end
    
  end
end