require 'savon'

module YodleeApi
  class CobrandLogin
    
    attr_reader :client, :cobrand_context, :endpoint
    
    def initialize(credentials, endpoint)
      @endpoint = endpoint
      
      @client = Savon::Client.new do
        wsdl.document = "#{Rails.root}/lib/wsdl/CobrandLogin.wsdl"
        wsdl.endpoint = "#{@endpoint}/CobrandLoginService"
      end        
    end

    def get_cobrand_context
      @cobrand_context = @client.request :login_cobrand do
        soap.xml =  <<-eos
          <soapenv:Envelope 
            xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/'
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
            xmlns:cob='http://cobrandlogin.login.core.soap.yodlee.com' 
            xmlns:common='http://common.soap.yodlee.com'
            xmlns:login='http://login.ext.soap.yodlee.com'>

            <soapenv:Header/>
            <soapenv:Body>
               <cob:loginCobrand>
                  <cobrandId>#{@credentials.cobrand_id}</cobrandId>
                  <applicationId>#{@credentials.application_id}</applicationId>
                  <tncVersion>1</tncVersion>             
                  <cobrandCredentials xsi:type="login:CobrandPasswordCredentials">
                    <loginName>#{@credentials.cobrand_login}</loginName>
                    <password>#{@credentials.cobrand_password}</password>
                  </cobrandCredentials>
               </cob:loginCobrand>
            </soapenv:Body>
          </soapenv:Envelope>
        eos
      end
    end


    def logout
      @client.request :logout, :body => {:cobrand_context => @cobrand_context}
    end
  end
end