require "yodlee_api/version"

module YodleeApi
  def initialize
    @client = Savon::Client.new do
      wsdl.document = "#{Rails.root}/lib/wsdl/CobrandLogin.wsdl"
      wsdl.endpoint = "https://64.41.182.230/yodsoap/services/CobrandLoginService"
    end        
  end
  
  def client
   @client
  end
  
  def login
    xml = <<-eos
            <soapenv:Envelope 
              xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/'
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
              xmlns:cob='http://cobrandlogin.login.core.soap.yodlee.com' 
              xmlns:common='http://common.soap.yodlee.com'
              xmlns:login='http://login.ext.soap.yodlee.com'>

              <soapenv:Header/>
              <soapenv:Body>
                 <cob:loginCobrand>
                    <cobrandId>10000556</cobrandId>
                    <applicationId>499D28D0A09754A9FF5285C084454E00</applicationId>
                    <tncVersion>1</tncVersion>             
                    <cobrandCredentials xsi:type="login:CobrandPasswordCredentials">
                      <loginName>SdkEval</loginName>
                      <password>S#k11@l$</password>
                    </cobrandCredentials>
                 </cob:loginCobrand>
              </soapenv:Body>
            </soapenv:Envelope>
          eos
    
    @cobrand_context = @client.request :login_cobrand do
      # soap.body = {
      #         :cobrand_id => "10000556",
      #         :application_id  => "499D28D0A09754A9FF5285C084454E00",
      #         :cobrand_credentials => {:cobrand_password_credentials => {:loginName => "SdkEval", :password => "S#k11@l$"}},
      #         :order! => ["ins5:cobrandId", "ins5:applicationId", "ins5:cobrandCredentials"]
      # 
      #       }
      soap.xml = xml
      puts @cobrand_context
    end
    
  end
  
  
  def logout
    @client.request :logout, :body => {:cobrand_context => @cobrand_context}
  end
  
end
