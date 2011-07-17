require 'savon'

module YodleeApi
  class CobrandLogin
    
    attr_accessor :client, :cobrand_context, :endpoint, :credentials, :document
    
    def initialize(endpoint, credentials)
      @endpoint = File.join(endpoint, "CobrandLoginService")
      @credentials = credentials
      @document = "#{File.dirname(__FILE__)}/wsdl/CobrandLogin.wsdl"
      
      @client = Savon::Client.new do
         wsdl.document = self.document
         wsdl.endpoint = self.endpoint
         wsdl.namespace = "http://cobrandlogin.login.core.soap.yodlee.com"
      end
    end
    

    def get_context    
        @response = @client.request :ins5, :login_cobrand do
          soap.element_form_default = :unqualified          
          
          soap.body = {
               "cobrandId" => credentials.cobrand_id,
               "applicationId" => credentials.application_id,
               "cobrandCredentials" => {"loginName" => credentials.cobrand_login, "password" => credentials.cobrand_password },
                                       :attributes! => { "cobrandCredentials" => { "xsi:type" => "login:CobrandPasswordCredentials"  } }
          }
      end
      
      parse_response
    end


    def parse_response
      hash_response = @response.to_hash
      @cobrand_context = hash_response[:login_cobrand_response][:login_cobrand_return]           
      "done"      
    end

    def logout
      @client.request :logout do
        soap.element_form_default = :unqualified          
         soap.body = {
           "cobrandContext" => {
             "cobrandId" => cobrand_context[:cobrand_id],
             "channelId" => cobrand_context[:channel_id],
             "tncVersion" => cobrand_context[:tnc_version],
             "applicationId" => cobrand_context[:application_id],
             "cobrandConversationCredentials" => {"sessionToken" => cobrand_context[:cobrand_conversation_credentials][:session_token] },
                :attributes! => { "cobrandConversationCredentials" => { "xsi:type" => cobrand_context[:cobrand_conversation_credentials][:"@xsi:type"]} },
             "preferenceInfo" => {
               "currencyCode" => cobrand_context[:preference_info][:currency_code],
               "timeZone" => cobrand_context[:preference_info][:time_zone],
               "dateFormat" => cobrand_context[:preference_info][:date_format],
               "currencyNotationType" => cobrand_context[:preference_info][:currency_notation_type],
               "numberFormat" => {
                 "decimalSeparator" => cobrand_context[:preference_info][:number_format][:decimal_separator],
                 "groupingSeparator" => cobrand_context[:preference_info][:number_format][:grouping_separator],
                 "groupPattern" => cobrand_context[:preference_info][:number_format][:group_pattern]
               } 
             }      
           }
         }
       end
    end
    
  end
end