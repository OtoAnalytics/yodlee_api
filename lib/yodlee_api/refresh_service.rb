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
    end; nil

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
    end; nil

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
  end
  
  
  def parse_refresh_info_return(xml_response)
    doc = Nokogiri::XML(response_xml)
    elements = doc.search('getRefreshInfo1Return/elements').map {|e| e.elements.inject({}) { |h, c| h[c.name.to_sym] = c.elements.size > 1 ? c.elements.map { |c| {c.name => c.text} } : c.text ; h }
    
    
    # <getRefreshInfo1Return>
    #                <elements>
    #                   <itemId>11628812</itemId>
    #                   <statusCode>402</statusCode>
    #                   <refreshType>2</refreshType>
    #                   <refreshRequestTime>0</refreshRequestTime>
    #                   <lastUpdatedTime>0</lastUpdatedTime>
    #                   <lastUpdateAttemptTime>1311973157</lastUpdateAttemptTime>
    #                   <itemAccessStatus>ACCESS_NOT_VERIFIED</itemAccessStatus>
    #                   <userActionRequiredType>CHANGE_CREDENTIALS</userActionRequiredType>
    #                   <userActionRequiredCode>402</userActionRequiredCode>
    #                   <userActionRequiredSince>2011-07-29T13:26:47.000-07:00</userActionRequiredSince>
    #                   <lastDataUpdateAttempt>
    #                      <date>2011-07-29T13:59:17.000-07:00</date>
    #                      <status>LOGIN_FAILURE</status>
    #                      <statusCode>402</statusCode>
    #                      <type>USER_REQUESTED</type>
    #                   </lastDataUpdateAttempt>
    #                   <lastUserRequestedDataUpdateAttempt>
    #                      <date>2011-07-29T13:59:17.000-07:00</date>
    #                      <status>LOGIN_FAILURE</status>
    #                      <statusCode>402</statusCode>
    #                      <type>USER_REQUESTED</type>
    #                   </lastUserRequestedDataUpdateAttempt>
    #                   <itemCreateDate>2011-07-29T13:26:44.000-07:00</itemCreateDate>
    #                   <nextUpdateTime>1934077866</nextUpdateTime>
    #                   <responseCodeType>USER_ERROR</responseCodeType>
    #                   <retryCount>2</retryCount>
    #                   <refreshMode>NORMAL</refreshMode>
    #                </elements>
    #             </getRefreshInfo1Return>
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