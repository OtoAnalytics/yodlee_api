yodlee_api
==========

https://github.com/OtoAnalytics/yodlee_api

Description:
------------

Soap client for the Yodlee API. Supports version 10.2.

Installation:
------------

```ruby
# Gemfile
gem 'yodlee_api', :git => "git@github.com:OtoAnalytics/yodlee_api.git"
```
QuickStart Guide:
-----------------

1) create a global config and put it somewhere like config/environment.rb

```ruby
YodleeApi.configure do |config| 
  config.application_id = "APP_ID" 
  config.cobrand_id = "COBRAND_ID"
  config.cobrand_login = "COBRAND_USERNAME"
  config.cobrand_password = "COBRAND_PASSWORD"
  config.locale = {:country => "US", :language => "en"} # optional
  config.tnc_version = 1 # optional
  config.endpoint = "https://some/endpoint/here"
end
```
 
 
2) Create a client and log in to the CobrandLoginService

```ruby
client = YodleeApi::CobrandLogin.new
```

If you don't have a global config, then you need to specify credentials and your endpoint. All fields are required unless commented as optional

```ruby
credentials = YodleeApi::CobrandCredentials.new(
  :cobrand_id => "YOUR_COBRAND_ID",
  :application_id => "YOUR_APPLICATION_ID",
  :cobrand_login => "YOUR_COBRAND_USERNAME",
  :cobrand_password => "YOUR_COBRAND_PASSWORD",
  :locale => = {:country => "US", :language => "en"}, # optional
  :tnc_version => 1 # optional
)

endpoint = "https://some/endpoint/here"
client = YodleeApi::CobrandLogin.new(endpoint, credentials)
```

3) Create user credentials (email is only required for registration)

```ruby  
user_creds = YodleeApi::UserCredentials.new(:email => "foo@bar.com", :login_name => "foobarone", :password => "foobartwo1")
```

4a) Register the user and log in

```ruby  
registration_manager = YodleeApi::UserRegistration.new(client.cobrand_context, user_creds)
```

4b) If you already have a user with those credentials, log in instead

```ruby  
login_manager = YodleeApi::UserLogin.new(client.cobrand_context, user_creds) 
```

5) Create a content service request to get the list of supported sites and their login forms

```ruby
services = YodleeApi::ContentServices.new(client.cobrand_context)
 

# Fetch the sites list for a container type
service.get_sites("bank")

# you can also specify an array of container_types, see YodleeApi::ContentServices::SupportedContainerTypes for a list of valid types
service.get_content_services(["bank", "credits"])

```

6) Access the sites list. The sites will be stored an array of hashes with keys :content_service_id, :site_name, :organization_name and :login_form

```ruby 
service.sites[2882]

=> { 
    :content_service_id=>"13356", 
    :site_name=>"WT Direct", 
    :organization_name=>"Wilmington Trust", 
    :login_form =>
      [
        {:name=>"PASSWORD", :displayName=>"Password", :isEditable=>"true", ... :fieldErrorCode=>""}, # each hash is a form field
        {:name=>"LOGIN", :displayName=>"User ID", :isEditable=>"true",... :fieldErrorCode=>""}, 
        {:name=>"OP_OPTIONS", :displayName=>"Question1", :isEditable=>"true", :isOptional=>"true", :isEscaped=>"false", :isOptionalMFA=>"false", :isMFA=>"false", 
          :validValues=>["city were you born in", "first name of the best man at your wedding", ... "name of your first pet"], 
          :displayValidValues=>["What city were you born in?", ... "What was the name of your first pet?"], 
          :valueIdentifier=>"OP_OPTIONS", :valueMask=>"LOGIN_FIELD", :fieldType=>"OPTIONS", :size=>"20", :maxlength=>"40", :fieldErrorCode=>""}, 
        {:name=>"OP_LOGIN3", :displayName=>"Answer1", :isEditable=>"true", ... :fieldErrorCode=>""}, 
      ]    
  }
```


7) Display the content services to a user and grab input for the appropriate login form. Implementation will vary.

8) Create an array of credential fields for the content service provider the user has chosen

```ruby  
credential_fields = [
  YodleeApi::CredentialFields.new(:name => "LOGIN", :display_name => "Online ID",  ..., :value => "fooooobarr", ... ),
  YodleeApi::CredentialFields.new(:name => "PASSWORD", :display_name => "Passcode",  ..., :value => "1234foobarr", ... ),
  YodleeApi::CredentialFields.new(:name => "", :display_name => "Verify Passcode",  ..., :value => "1234foobarr", ... ) 
]
```
  
9) Add an account for the user

```ruby
item_manager = YodleeApi::ItemManagement.new
# this method expects a user context (from registration_manager or login_manager), a content service id and an array of credential fields 
# corresponding to the fields in that content service's login form
item_manager.add_account_for_content_service(login_manager.user_context, 2931, credential_fields)
```

10) Start an account refresh

```ruby
refresh_service = YodleeApi::RefreshService.new(login_manager.user_context)
refresh_service.start_refresh(item_manager.item_id)
```

11) Poll the refresh service until item is done refreshing

```ruby
loop do
  break if refresh_service.is_item_refreshing(item_manager.item_id) == false
  sleep 2
end

```

12) Get the refresh info and proceed if status code is 0

```ruby
info_hash = refresh_service.get_refresh_info
status_code = info_hash["statusCode"].to_i

if status_code == 0
  # success, proceed to step 14
elsif status_code == 402
  # invalid credentials, present login form to user to try again and proceed to step 13
end
```

13) Update credentials if user passed in incorrect credentials and go back to step 10
 
```ruby 
item_manager.update_credentials_for_item(login_manager.user_context, item_manager.item_id, credential_fields)
```

14) Grab the account summaries

```ruby
data_service = YodleeApi::DataService.new(login_manager.user_context)
accounts = data_service.get_account_summaries

# The account summaries returned will be arrays of hashes with the format
=>[
    {:account_id=>"11076596", :account_name=>"MyAccess Checking-0123"},
    {:account_id=>"11076597", :account_name=>"MyAccess Savings-4567"}
  ] 

```

15) Create a transaction search request using an account id fetched in step 14, the only required parameter is :account_id, 
however, you can customize the search request by passing in values for other parameters. See  `YodleeApi::TransactionSearchRequest::Parameters`
for possible values.

```ruby
search_request = YodleeApi::TransactionSearchRequest.new(:account_id => 11076596)
```

16) Fetch transactions using the transaction search service

```ruby
search_service = YodleeApi::TransactionSearch.new(login_manager.user_context)
search_service.fetch_transactions(search_request)
```

The transactions will be stored in a hash with the following format:

```ruby
search_service.transactions
=>[
    {:transaction_id=>"23902396", :description=>"CHECKCARD 0725 CURRY UP NOW (TRUCK 2) SOUTH SAN FRACA xxxxxxxxxxxxxxxxxxx0000", :category_name=>"Restaurants/Dining", :categorization_keyword=>"curry", :amount=>"14.0", :currency_code=>"USD"}, 
    {:transaction_id=>"23902600", :description=>"USPS xxxxxxxxx 07/25 #xxxxx2102 PURCHASE USPS xxxxxx0000/U PALO ALTO CA", :category_name=>"Postage and Shipping", :categorization_keyword=>"usps", :amount=>"29.95", :currency_code=>"USD"}
  ]

```

Dependencies:
-------------

```ruby
savon, '>= 0.9.6'
nokogiri, '>= 1.4.0'
ruby, '1.9.2' #(hashes in 1.8.7 don't store element order and that will cause all sorts of havoc)
```

LICENSE:
--------

Coming Soon.