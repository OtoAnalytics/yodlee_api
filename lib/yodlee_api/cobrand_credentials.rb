module YodleeApi
  class CobrandCredentials 
    attr_accessor :cobrand_id, :application_id, :cobrand_login, :cobrand_password
    
    def initialize args
      args.each do |k,v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end    
  end
end