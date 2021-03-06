module YodleeApi
  class DataService
    
  attr_accessor :soap_service
  attr_writer :endpoint
  attr_reader :client

  # gets the endpoint, defaults to globally defined endpoint
  def endpoint
    @endpoint || YodleeApi.endpoint
  end

  # returns a deep copy of the user context, this will only be available after successful registration
  def user_context
    YodleeApi.deep_copy(@user_context)
  end
  
  def get_account_summaries
    response = client.request :dat, :get_item_summaries do
      soap.element_form_default = :unqualified     
      soap.namespaces["xmlns:login"] = 'http://login.ext.soap.yodlee.com'

      soap.body = {
       :ctx => user_context,
      }
    end

    response_xml = response.to_xml
    parse_item_summaries(response_xml)
    
  end
  
  private

  def parse_item_summaries(response_xml)
    doc = Nokogiri::XML(response_xml)
    response_hash = doc.search('itemData/accounts/elements').map { |account| 
      { 
        :account_id => account.search('accountId').text,
        :account_name => account.search('accountName').text 
      }
    }   
  end
  
  
  def initialize(ctxt)
    @soap_service = "DataService"
    @user_context = ctxt
    @client = Savon::Client.new do
       http.auth.ssl.verify_mode = :none              
       wsdl.endpoint = File.join(endpoint, soap_service)
       wsdl.namespace = "http://dataservice.dataservice.core.soap.yodlee.com" 
    end
  end
  
  end
end