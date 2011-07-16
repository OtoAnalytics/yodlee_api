require 'savon'

module YodleeApi
  class CobrandLogin
    
    attr_accessor :client, :cobrand_context, :endpoint, :credentials, :document
    
    def initialize(endpoint, credentials)
      @endpoint = File.join(endpoint, "CobrandLoginService")
      @credentials = credentials
      @document = "#{File.dirname(__FILE__)}/wsdl/CobrandLogin.wsdl"
    end

    def omg
      puts @credentials.cobrand_id
      puts @credentials.application_id
      puts @credentials.cobrand_login
      puts @credentials.cobrand_password
    end

    def get_context
        
        
      xml = "<soapenv:Envelope 
        xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/'
        xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'
        xmlns:cob='http://cobrandlogin.login.core.soap.yodlee.com' 
        xmlns:common='http://common.soap.yodlee.com'
        xmlns:login='http://login.ext.soap.yodlee.com'>

        <soapenv:Header/>
        <soapenv:Body>
           <cob:loginCobrand>
              <cobrandId>#{@credentials.cobrand_id}</cobrandId>
              <applicationId>#{@credentials.application_id}</applicationId>
              <tncVersion>1</tncVersion>             
              <cobrandCredentials xsi:type='login:CobrandPasswordCredentials'>
                <loginName>#{@credentials.cobrand_login}</loginName>
                <password>#{@credentials.cobrand_password}</password>
              </cobrandCredentials>
           </cob:loginCobrand>
        </soapenv:Body>
      </soapenv:Envelope>"
      
     @client = Savon::Client.new do
        wsdl.document = @document
        wsdl.endpoint = @endpoint
      end
      
      @cobrand_context = @client.request :login_cobrand do
        soap.xml = xml
      end
    end


    def logout
      @client.request :logout, :body => {:cobrand_context => @cobrand_context}
    end
  end
end