json.extract! paymentmethod, :id, :user_id, :method, :card_name, :card_type, :customer_id, :card_exp_date, :created_at, :updated_at
json.url paymentmethod_url(paymentmethod, format: :json)
