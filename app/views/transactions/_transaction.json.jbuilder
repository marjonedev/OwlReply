json.extract! transaction, :id, :user_id, :reference, :payment_provider, :timestamp, :reversed, :amount, :created_at, :updated_at
json.url transaction_url(transaction, format: :json)
