module YodleeApi
  
  #   A service interface that handles traversal of ContentServices which are "ON" for the cobrand. 
  #   This ContentServiceTraversal interface allows retrieval of all the ContentServices, as well as retrieving
  #   ContentServices based on a classification of the ContentServices (for e.g., a CATEGORY_LEVEL1 group that
  #   contains multiple CATEGORY_LEVEL2 groups which may in turn contain CATEGORY_LEVEL3 groups in addition to 
  #   multiple ContentServices).
  
  class ContentServices
  
    attr_accessor :container_types
    attr_writer :endpoint
    attr_reader :client, :sites, :cobrand_context, :soap_service, :response
    
    # list of supported container types, see Yodlee 10.2 API docs for ContainerTypes
    SupportedContainerTypes = 
      %w[bank credits travel auction bank bills bill_payment cable_satellite calendar rentals charts chats 
        consumer_guide credits deal hotel_reservations insurance stocks jobs loans mail messageboards minutes 
        miscellaneous mortgage news orders other_assets other_liabilities reservations miles telephone utilities]
    # gets the endpoint, defaults to globally defined endpoint
    def endpoint
      @endpoint || YodleeApi.endpoint
    end
    
    # returns a deep copy of the cobrand context; Savon strips out the !attributes elements and makes the 
    # context invalid, that's why a deep copy is needed
    def cobrand_context
      YodleeApi.deep_copy(@cobrand_context)
    end
    
    
    # Returns a Map of content services keyed by the container types.
    def get_sites(container_types)
      @response = client.request :con, :get_content_services_by_container_type5 do
        soap.element_form_default = :unqualified     
        soap.namespaces["xmlns:login"] = 'http://login.ext.soap.yodlee.com'
                   
        soap.body = {
         :cobrand_context => cobrand_context,
         :container_types => {
           :elements => container_types
         },
         :req_specifier => 16 # grab login forms
        }
      end
      
      @sites = @response.to_xml
      response_xml = @response.to_xml
      parse_response(response_xml)
    end
    
    private
    

    def initialize(ctxt)
      @cobrand_context = ctxt
      @soap_service = "ContentServiceTraversalService"
      @sites = []

      @client = Savon::Client.new do
         http.auth.ssl.verify_mode = :none              
         wsdl.endpoint = File.join(endpoint, soap_service)
         wsdl.namespace = "http://contentservicetraversal.traversal.ext.soap.yodlee.com"
      end
    end
    
    # parses the get_content_services_by_container_type5 response, extracting site name and content_service_id 
    def parse_response(response_xml)
        doc = Nokogiri::XML(response_xml)
        @sites = doc.search('getContentServicesByContainerType5Return/table/value/elements').find_all { |s| s.at("country").text == "US" }.map { |c| {
        # @sites = doc.search('getContentServicesByContainerType5Return/table/value/elements').map {|c| {
            :content_service_id => c.elements[0].text, 
            :site_name => c.elements[2].text, 
            :organization_name => c.elements[4].text,
            :login_form  => c.search('loginForm/componentList/elements', 'loginForm/componentList/elements/fieldInfoList/elements').map { |field| 
              field.elements.inject({}) { |h, c| 
                if ['validValues', 'displayValidValues'].include?(c.name)
                  h[c.name.to_sym] = c.elements.map { |c| c.text }
                else
                  h[c.name.to_sym] = c.text 
                end
                h 
              } 
            }
          }
        }; true     
    end
    
  end
end
