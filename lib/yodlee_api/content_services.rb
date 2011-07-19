module YodleeApi
  
  #   A service interface that handles traversal of ContentServices which are "ON" for the cobrand. 
  #   This ContentServiceTraversal interface allows retrieval of all the ContentServices, as well as retrieving
  #   ContentServices based on a classification of the ContentServices (for e.g., a CATEGORY_LEVEL1 group that
  #   contains multiple CATEGORY_LEVEL2 groups which may in turn contain CATEGORY_LEVEL3 groups in addition to 
  #   multiple ContentServices).
  
  class ContentServices
  
    attr_accessor :container_types
    attr_writer :endpoint
    attr_reader :client, :sites, :cobrand_context, :container_types, :soap_service
    
    # list of supported container types, see Yodlee 10.2 API docs for ContainerTypes
    SupportedContainerTypes = ["bank", "credit_card"]
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
    def get_content_services
      @response = client.request :con, :get_content_services_by_container_type4 do
        soap.element_form_default = :unqualified     
        soap.namespaces["xmlns:login"] = 'http://login.ext.soap.yodlee.com'
                   
        soap.body = {
         :cobrand_context => cobrand_context,
         :container_types => {
           :elements => container_types
         }
        }
      end
      
      hash_response = @response.to_hash
      sites_list = hash_response[:get_content_services_by_container_type4_response][:get_content_services_by_container_type4_return][:table][:value][:elements]
      parse_response(sites_list)
    end
    
    private
    
    Arguments = [:cobrand_context, :container_types]

    def initialize args
      args.each do |k, v|
        raise ArgumentError, "Invalid Parameters specified: #{k}, valid parameters are #{Arguments}" unless Arguments.include? k
        instance_variable_set("@#{k}", v) unless v.nil?
      end
      
      @soap_service = "ContentServiceTraversalService"
      @sites = []

      @client = Savon::Client.new do
         http.auth.ssl.verify_mode = :none              
         wsdl.endpoint = File.join(endpoint, soap_service)
         wsdl.namespace = "http://contentservicetraversal.traversal.ext.soap.yodlee.com"
      end
    end
    
    # parses the get_content_services_by_container_type4 response, extracting site name and content_service_id 
    def parse_response(sites_list)
      sites_list.each do |site|
        @sites << { :content_service_id => site[:content_service_id], :site_name => site[:site_display_name] }
      end
    end
    
  end
end