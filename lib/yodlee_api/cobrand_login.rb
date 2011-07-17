require 'savon'

module YodleeApi
  class CobrandLogin
    
    attr_writer :endpoint
    attr_accessor :client, :cobrand_context, :credentials, :document, :soap_service
    
    def initialize(endpt = nil, creds = {})
      raise "Invalid credentials, expected an instance of Yodlee:CobrandCredentials" unless creds.class == "Yodlee::CobrandCredentials"
      @soap_service = "CobrandLoginService"
      @credentials = creds || YodleeApi::CobrandCredentials.new
      @endpoint = endpt
      
      Savon.configure do |config| 
        config.env_namespace= :soapenv 
      end
      
      @client = Savon::Client.new do
         wsdl.endpoint = File.join(endpoint, soap_service)
         wsdl.namespace = "http://cobrandlogin.login.core.soap.yodlee.com"
      end
    end
    
    # Returns the endpoint. Defaults to global endpoint.
    def endpoint
      @endpoint ||= YodleeApi.endpoint
    end
      

    # Logs in to the CobrandLoginService and sets cobrand_context from the returned response
    def login    
        @response = self.client.request :cob, :login_cobrand do
          soap.element_form_default = :unqualified     
          soap.namespaces["xmlns:login"] = 'http://login.ext.soap.yodlee.com'
          soap.namespaces["xmlns:common"] = "http://common.soap.yodlee.com"
               
          soap.body = {
           :cobrand_id => credentials.cobrand_id,
           :application_id => credentials.application_id,
           :tnc_version => 1,             
           :cobrand_credentials => {:login_name => credentials.cobrand_login, :password => credentials.cobrand_password, :order! => [:login_name, :password] },
                                   :attributes! => { :cobrand_credentials => { "xsi:type" => "login:CobrandPasswordCredentials"  } },
           :order! => [:cobrand_id, :application_id, :tnc_version, :cobrand_credentials] 
          }
      end
      
      parse_response
    end


    # logs out of the CobrandLoginService
    def logout
      raise "Cannot log out with out a context." if cobrand_context.nil?
      @client.request :cob, :logout do
        soap.namespaces["xmlns:common"] = "http://common.soap.yodlee.com"
        soap.namespaces["xmlns:login"] = 'http://login.ext.soap.yodlee.com'
        
        soap.element_form_default = :unqualified          
         soap.body = cobrand_context
       end
    end
    
    private
    
    def parse_response
      hash_response = @response.to_hash
      context = hash_response[:login_cobrand_response][:login_cobrand_return]    
      @cobrand_context = {
        :cobrand_context => {
          :cobrand_id => context[:cobrand_id],
          :channel_id => context[:channel_id],
          :tnc_version => context[:tnc_version],
          :application_id => context[:application_id],
          :cobrand_conversation_credentials => {:session_token => context[:cobrand_conversation_credentials][:session_token] },
            :attributes! => { :cobrand_conversation_credentials => { "xsi:type" => "login:SessionCredentials"} },
          :preference_info => {
           :currency_code => context[:preference_info][:currency_code],
           :time_zone => context[:preference_info][:time_zone],
           :date_format => context[:preference_info][:date_format],
           :currency_notation_type => context[:preference_info][:currency_notation_type],
           :number_format => {
             :decimal_separator => context[:preference_info][:number_format][:decimal_separator],
             :grouping_separator => context[:preference_info][:number_format][:grouping_separator],
             :group_pattern => context[:preference_info][:number_format][:group_pattern],
             :order! => [:decimal_separator, :grouping_separator, :group_pattern]
           },
           :order! => [:currency_code, :time_zone, :date_format, :currency_notation_type, :number_format] 
          },
          :order! => [:cobrand_id, :channel_id, :tnc_version, :application_id, :cobrand_conversation_credentials, :preference_info]
        }
      }       
      "done"      
    end
    
    
  end
end