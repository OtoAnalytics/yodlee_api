require 'savon'

module YodleeApi
  class CobrandLogin
    
    attr_writer :endpoint
    attr_reader :client, :cobrand_context, :credentials, :soap_service
    
    
    # Returns the endpoint. Defaults to global endpoint.
    def endpoint
      @endpoint ||= YodleeApi.endpoint
    end
      

    # Attempts authentication of a cobrand in the Yodlee software platform and returns a valid CobrandContext if the authentication is successful.
    def login    
        @response = client.request :cob, :login_cobrand do
          soap.element_form_default = :unqualified     
          soap.namespaces["xmlns:login"] = 'http://login.ext.soap.yodlee.com'
          soap.body = {
           :cobrand_id => credentials.cobrand_id,
           :application_id => credentials.application_id,
           :locale => credentials.locale,
           :tnc_version => 1,             
           :cobrand_credentials => {:login_name => credentials.cobrand_login, :password => credentials.cobrand_password },
                                   :attributes! => { :cobrand_credentials => { "xsi:type" => "login:CobrandPasswordCredentials"  } }
          }
      end
      
      hash_response = @response.to_hash
      context = hash_response[:login_cobrand_response][:login_cobrand_return]
      parse_response(context)
    end


    # Logs out a cobrand from the Yodlee software platform.
    def logout
      raise "Cannot log out without a context." if cobrand_context.nil?
      client.request :cob, :logout do
        soap.namespaces["xmlns:login"] = 'http://login.ext.soap.yodlee.com'
        soap.element_form_default = :unqualified          
        soap.body = { :cobrand_context => cobrand_context }
      end
      @cobrand_context = nil
    end
    
    
    # Renews the absolute timeout validity of the com.yodlee.soap.common.ConversationCredentials encpasulated in the CobrandContext.
    def renew_conversation
      raise "Cannot renew conversation without a context." if cobrand_context.nil?
      @response = client.request :cob, :renew_conversation do
        soap.namespaces["xmlns:login"] = 'http://login.ext.soap.yodlee.com'
        soap.element_form_default = :unqualified          
        soap.body = { :cobrand_context => cobrand_context }
      end
      
      hash_response = @response.to_hash
      context = hash_response[:renew_conversation_response][:renew_conversation_return]
      parse_response(context)
    end
    
    private
    
    def initialize(endpt = nil, creds = {})
      @soap_service = "CobrandLoginService"
      @credentials = creds.empty? ? YodleeApi::CobrandCredentials.new : creds
      @endpoint = endpt
      
      Savon.configure do |config| 
        config.env_namespace= :soapenv 
      end
      
      @client = Savon::Client.new do
         http.auth.ssl.verify_mode = :none              
         wsdl.endpoint = File.join(endpoint, soap_service)
         wsdl.namespace = "http://cobrandlogin.login.core.soap.yodlee.com"
      end
    end
    
    # extracts cobrand_context in hash format from login and renew_conversation responses
    def parse_response(context)       
      @cobrand_context = {
        :cobrand_id => context[:cobrand_id],
        :channel_id => context[:channel_id],
        :locale => { 
          :country => context[:locale][:country], 
          :language => context[:locale][:language], 
          :variant => context[:locale][:variant] 
        },
        :tnc_version => context[:tnc_version],
        :application_id => context[:application_id],
        :cobrand_conversation_credentials => {
          :session_token => context[:cobrand_conversation_credentials][:session_token],
          :attributes! => { :cobrand_conversation_credentials => { "xsi:type" => "login:SessionCredentials"} } 
        },
        :preference_info => {
          :currency_code => context[:preference_info][:currency_code],
          :time_zone => context[:preference_info][:time_zone],
          :date_format => context[:preference_info][:date_format],
          :currency_notation_type => context[:preference_info][:currency_notation_type],
          :number_format => {
            :decimal_separator => context[:preference_info][:number_format][:decimal_separator],
            :grouping_separator => context[:preference_info][:number_format][:grouping_separator],
            :group_pattern => context[:preference_info][:number_format][:group_pattern]
          }
        }
      }
            
    end
    
  end
end


