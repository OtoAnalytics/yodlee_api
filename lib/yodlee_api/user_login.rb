module YodleeApi
  
  # A service interface that authenticates a user against the Yodlee software platform and allows a 
  # user to extend the valid (active) time of a user session.
  class UserLogin
    
    attr_accessor :credentials, :soap_service
    attr_writer :endpoint
    attr_reader :client
    
    # gets the endpoint, defaults to globally defined endpoint
    def endpoint
      @endpoint || YodleeApi.endpoint
    end
    
    # returns a deep copy of the cobrand context; Savon strips out the !attributes elements and makes the 
    # context invalid, that's why a deep copy is needed
    def cobrand_context
      YodleeApi.deep_copy(@cobrand_context)
    end
    
    # returns a deep copy of the user context, this will only be available after successful registration
    def user_context
      YodleeApi.deep_copy(@user_context)
    end
    
    # Attempts authentication of a user to the Yodlee software platform and logs in the user if the authentication is successful.
    def login()
      @response = client.request :log, :login2 do
        soap.element_form_default = :unqualified     
        soap.namespaces["xmlns:login"] = 'http://login.ext.soap.yodlee.com'
                   
        soap.body = {
         :cobrand_context => cobrand_context,
         :user_credentials => credentials.credentials_hash, 
         :attributes! => {:user_credentials => {"xsi:type" => "login:PasswordCredentials"}}       
        }
      end
      
      hash_response = @response.to_hash
      context = hash_response[:login2_response][:login2_return][:user_context]
      parse_response(context)
    end
    
    # Unregisters a user from the Yodlee software platfiorm.
    def logout
      raise "Cannot logout without a user context." if user_context.nil?
      
      @response = client.request :user, :logout do
        soap.element_form_default = :unqualified     
        soap.namespaces["xmlns:login"] = 'http://login.ext.soap.yodlee.com'

        soap.body = {
          :user_context => user_context   
        }
      end

      @user_context = nil
    end
    
    private
      
    def initialize(cob_ctxt, creds)
      @soap_service = "LoginService"
      @credentials = creds
      @cobrand_context = cob_ctxt

      @client = Savon::Client.new do
         http.auth.ssl.verify_mode = :none              
         wsdl.endpoint = File.join(endpoint, soap_service)
         wsdl.namespace = "http://login.login.core.soap.yodlee.com"
      end
    end
    
    # parses the response of login2 and extracts the user_context
    def parse_response(context)       
      @user_context = {
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
          :session_token => context[:cobrand_conversation_credentials][:session_token]
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
        },
        :conversation_credentials => {
          :session_token =>  context[:conversation_credentials][:session_token]
        }, 
        :valid => context[:valid],
        :is_password_expired => context[:is_password_expired],
        :attributes! => {
          :conversation_credentials => {"xsi:type" => "login:SessionCredentials"},
          :cobrand_conversation_credentials => { "xsi:type" => "login:SessionCredentials"}
        }
      }
    end
  end
end


