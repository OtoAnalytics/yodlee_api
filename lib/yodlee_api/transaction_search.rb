module YodleeApi
  class TransactionSearch
    
    attr_accessor :soap_service
    attr_writer :endpoint
    attr_reader :client, :transactions

    # gets the endpoint, defaults to globally defined endpoint
    def endpoint
      @endpoint || YodleeApi.endpoint
    end

    # returns a deep copy of the user context, this will only be available after successful registration
    def user_context
      YodleeApi.deep_copy(@user_context)
    end

    def fetch_transactions(search_request)
      response = client.request :tran, :execute_user_search_request do
        soap.element_form_default = :unqualified     
        soap.namespaces["xmlns:login"] = 'http://login.ext.soap.yodlee.com'

        soap.body = {
         :user_context => user_context,
         :transaction_search_request => search_request.search_hash
        }
      end

      response_xml = response.to_xml
      parse_transactions(response_xml)

    end

    private
 
    def parse_transactions(response_xml)
      doc = Nokogiri::XML(response_xml)
      response_hash = doc.search('searchResult/transactions/elements').map { |transaction| 
        { 
          :transaction_id => transaction.search('transactionId').text,
          :description => transaction.search('description/description').text,
          :category_name => transaction.search('categoryName').text,
          :categorization_keyword => transaction.search('categorizationKeyword').text,
          :amount => transaction.search('amount/amount').text,
          :currency_code => transaction.search('amount/currencyCode').text
        }
      }   
    end


    def initialize(ctxt)
      @soap_service = "TransactionSearchService"
      @user_context = ctxt
      @client = Savon::Client.new do
         http.auth.ssl.verify_mode = :none              
         wsdl.endpoint = File.join(endpoint, soap_service)
         wsdl.namespace = "http://transactionsearchservice.transactionsearch.core.soap.yodlee.com" 
      end
    end
    
    
  end
end


