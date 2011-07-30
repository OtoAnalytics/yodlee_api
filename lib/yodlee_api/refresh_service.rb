module YodleeApi
  class RefreshService
    
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
  
  def start_refresh(item_id)
    response = client.request :ref, :start_refresh7 do
      soap.element_form_default = :unqualified     
      soap.namespaces["xmlns:login"] = 'http://login.ext.soap.yodlee.com'
      soap.namespaces["xmlns:common"]= "http://common.soap.yodlee.com"

      soap.body = {
       :user_context => user_context,
       :item_id => item_id,
       :refresh_parameters => {
         :refresh_priority => 1,
         :force_refresh => true,
         :refresh_mode => "NORMAL_REFRESH_MODE"
       }
      }
    end

    response_xml = response.to_xml
    doc = Nokogiri::XML(response_xml)
    status = doc.search('startRefresh7Return').text
  end
  
  
  def is_item_refreshing(item_id)
    response = client.request :ref, :is_item_refreshing do
      soap.element_form_default = :unqualified     
      soap.namespaces["xmlns:login"] = 'http://login.ext.soap.yodlee.com'
      soap.namespaces["xmlns:common"]= "http://common.soap.yodlee.com"

      soap.body = {
       :user_context => user_context,
       :mem_item_id => item_id
      }
    end

    response_xml = response.to_xml
    doc = Nokogiri::XML(response_xml)
    status = doc.search('isItemRefreshingReturn').text
    
    if status == "true"
      true
    else
      false
    end
  end
  
  def get_refresh_info(item_ids)
     response = client.request :ref, :get_refresh_info1 do
       soap.element_form_default = :unqualified     
       soap.namespaces["xmlns:login"] = 'http://login.ext.soap.yodlee.com'
       soap.namespaces["xmlns:common"]= "http://common.soap.yodlee.com"

       soap.body = {
        :user_context => user_context,
        :item_ids => {
          :elements => item_ids
        }
       }
     end

     response_xml = response.to_xml
     parse_refresh_info_return(response_xml)
  end
  
  
  def parse_refresh_info_return(response_xml)
    doc = Nokogiri::XML(response_xml)
    response_hash = doc.search('getRefreshInfo1Return/elements').map { |field| 
      field.elements.inject({}) { |h, c| 
        if c.elements.size > 1
          h[c.name] = c.elements.inject({}) {|a, b| a[b.name] = b.text ;  a }
        else
          h[c.name] = c.text 
        end
        h 
      } 
    }.first
  end
  
  private
  
  def initialize(ctxt)
    @soap_service = "RefreshService"
    @user_context = ctxt
    @client = Savon::Client.new do
       http.auth.ssl.verify_mode = :none              
       wsdl.endpoint = File.join(endpoint, soap_service)
       wsdl.namespace = "http://refresh.refresh.core.soap.yodlee.com" 
    end
  end
  
  end
end