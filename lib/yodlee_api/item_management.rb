module YodleeApi
  
  # A service interface that handles Item management in the Yodlee 5 platform. This interface allows users to
  # add new Member Items, edit the authentication credentials and delete existing Member Items from the system.
  # The interface also supports methods to retrieve the fields required for adding a particular ContentService.
  # 2931
  class ItemManagement
    
    attr_accessor :soap_service
    attr_writer :endpoint
    attr_reader :client, :item_id
  
    # gets the endpoint, defaults to globally defined endpoint
    def endpoint
      @endpoint || YodleeApi.endpoint
    end

    # returns a deep copy of the user context, this will only be available after successful registration
    def user_context
      YodleeApi.deep_copy(@user_context)
    end
    

    def add_account_for_content_service(ctxt, cs_id, fields)
      response = client.request :item, :add_item_for_content_service1 do
        soap.element_form_default = :unqualified     
        soap.namespaces["xmlns:login"] = 'http://login.ext.soap.yodlee.com'
        soap.namespaces["xmlns:common"]= "http://common.soap.yodlee.com"

        soap.body = {
         :user_context => ctxt,
         :content_service_id => cs_id,
         :credential_fields => {
           :elements => fields.map {|c| c.field_hash},
           :attributes! => {:elements => {"xsi:type" => "common:FieldInfoSingle"} }
         },
         :share_credentials_within_site => false,
         :start_refresh_item_on_update => true
        }
      end; nil

      response_xml = response.to_xml
      parse_account_response(response_xml)
    end
    
    
    def update_credentials_for_item(ctxt, item_id, fields)
      response = client.request :item, :update_credentials_for_item1 do
        soap.element_form_default = :unqualified     
        soap.namespaces["xmlns:login"] = 'http://login.ext.soap.yodlee.com'
        soap.namespaces["xmlns:common"]= "http://common.soap.yodlee.com"

        soap.body = {
         :user_context => ctxt,
         :item_id => item_id,
         :credential_fields => {
           :elements => fields.map {|c| c.field_hash},
           :attributes! => {:elements => {"xsi:type" => "common:FieldInfoSingle"} }
         },
         :start_refresh_item_on_addition => true
        }
      end; nil

      response_xml = response.to_xml
    end
    
    private
        
    
    def initialize
      @soap_service = "ItemManagementService"

      @client = Savon::Client.new do
         http.auth.ssl.verify_mode = :none              
         wsdl.endpoint = File.join(endpoint, soap_service)
         wsdl.namespace = "http://itemmanagement.accountmanagement.core.soap.yodlee.com"
      end   
    end

    
    
    def parse_account_response(response_xml)
      doc = Nokogiri::XML(response_xml)
      @item_id = doc.search('addItemForContentService1Return').text
    end
    
  end
end