require 'savon'

module YodleeApi
  class CobrandLogin
    
    attr_accessor :client, :cobrand_context, :endpoint, :credentials, :document
    
    def initialize(endpoint, credentials)
      @endpoint = File.join(endpoint, "CobrandLoginService")
      @credentials = credentials
      
      Savon.configure do |config| 
        config.env_namespace= :soapenv 
      end
      
      @client = Savon::Client.new do
         wsdl.endpoint = self.endpoint
         wsdl.namespace = "http://cobrandlogin.login.core.soap.yodlee.com"
      end
    end
    
  


    def get_context    
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


    def parse_response
      hash_response = @response.to_hash
      @cobrand_context = hash_response[:login_cobrand_response][:login_cobrand_return]           
      "done"      
    end

    def logout
      @client.request :cob, :logout do
        soap.namespaces["xmlns:common"] = "http://common.soap.yodlee.com"
        soap.namespaces["xmlns:login"] = 'http://login.ext.soap.yodlee.com'
        
        soap.element_form_default = :unqualified          
         soap.body = {
           :cobrand_context => {
             :cobrand_id => cobrand_context[:cobrand_id],
             :channel_id => cobrand_context[:channel_id],
             :tnc_version => cobrand_context[:tnc_version],
             :application_id => cobrand_context[:application_id],
             :cobrand_conversation_credentials => {:session_token => cobrand_context[:cobrand_conversation_credentials][:session_token] },
                :attributes! => { :cobrand_conversation_credentials => { "xsi:type" => "login:SessionCredentials"} },
             :preference_info => {
               :currency_code => cobrand_context[:preference_info][:currency_code],
               :time_zone => cobrand_context[:preference_info][:time_zone],
               :date_format => cobrand_context[:preference_info][:date_format],
               :currency_notation_type => cobrand_context[:preference_info][:currency_notation_type],
               :number_format => {
                 :decimal_separator => cobrand_context[:preference_info][:number_format][:decimal_separator],
                 :grouping_separator => cobrand_context[:preference_info][:number_format][:grouping_separator],
                 :group_pattern => cobrand_context[:preference_info][:number_format][:group_pattern],
                 :order! => [:decimal_separator, :grouping_separator, :group_pattern]
               },
               :order! => [:currency_code, :time_zone, :date_format, :currency_notation_type, :number_format] 
             },
             :order! => [:cobrand_id, :channel_id, :tnc_version, :application_id, :cobrand_conversation_credentials, :preference_info]
           }
         }
       end
    end
    
  end
end