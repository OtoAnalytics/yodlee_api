module YodleeApi
  class TransactionSearchRequest
    

      attr_accessor :account_id, :sort_by_container, :sort_by_item_account_id, :start_number, :end_number, :ignore_user_input, :container_type,
                    :ignore_manual_transactions, :ignore_payment_transactions, :ignore_ft_transactions, :ignore_pending_transactions, :compute_running_balance, 
                    :compute_projected_balance, :fetch_future_transactions, :include_aggregated_transactions, :calculate_transaction_balance, :ignore_transfer_category_transactions,
                    :is_shared_account_transaction_req, :first_call, :is_available, :ignore_bank_transactions, :ignore_card_transactions, :ignore_loan_transactions, 
                    :ignore_insurance_transactions, :ignore_investment_transactions, :for_spending_reports, :enable_projected_transaction_partitioning

            
      def search_hash
        {
          :search_filter => { 
            :item_account_id => { :identifier => account_id },
            :sort_by_container => sort_by_container || false,
            :sort_by_item_account_id => sort_by_item_account_id || false
          },
          :result_range => {
            :start_number => start_number || 1, 
            :end_number => end_number || 100
          }, 
          :ignore_user_input => ignore_user_input || true, 
          :container_type => container_type || "all",        
          :ignore_manual_transactions => ignore_manual_transactions || false, 
          :ignore_payment_transactions => ignore_payment_transactions || false, 
          "ignoreFTTransactions" => ignore_ft_transactions || false, 
          :ignore_pending_transactions => ignore_pending_transactions || false, 
          :compute_running_balance => compute_running_balance || false, 
          :compute_projected_balance => compute_projected_balance || false, 
          :fetch_future_transactions => fetch_future_transactions || false, 
          :include_aggregated_transactions => include_aggregated_transactions || true, 
          :calculate_transaction_balance => calculate_transaction_balance || false, 
          :ignore_transfer_category_transactions => ignore_transfer_category_transactions || false,
          :is_shared_account_transaction_req => is_shared_account_transaction_req || false, 
          :first_call => first_call || false, 
          :is_available => is_available || false, 
          :ignore_bank_transactions => ignore_bank_transactions || false, 
          :ignore_card_transactions => ignore_card_transactions || false, 
          :ignore_loan_transactions => ignore_loan_transactions || false, 
          :ignore_insurance_transactions => ignore_insurance_transactions || false, 
          :ignore_investment_transactions => ignore_investment_transactions || false, 
          :for_spending_reports => for_spending_reports || false, 
          :enable_projected_transaction_partitioning => enable_projected_transaction_partitioning || false 
        }
      end


      Attributes = [ :account_id, :sort_by_container, :sort_by_item_account_id, :start_number, :end_number, :ignore_user_input, :container_type,
                    :ignore_manual_transactions, :ignore_payment_transactions, :ignore_ft_transactions, :ignore_pending_transactions, :compute_running_balance, 
                    :compute_projected_balance, :fetch_future_transactions, :include_aggregated_transactions, :calculate_transaction_balance, :ignore_transfer_category_transactions,
                    :is_shared_account_transaction_req, :first_call, :is_available, :ignore_bank_transactions, :ignore_card_transactions, :ignore_loan_transactions, 
                    :ignore_insurance_transactions, :ignore_investment_transactions, :for_spending_reports, :enable_projected_transaction_partitioning 
                   ]
      
      private
             
      def initialize args
        raise ArgumentError, "Cannot create a transaction search request without an account identifier" unless args.keys.include? :account_id
        args.each do |k,v|
          raise ArgumentError, "Invalid argument specified: #{k}" unless Attributes.include? k
          instance_variable_set("@#{k}", v) unless v.nil?
        end
      end

    
  end
end

