json.extract! emailaccount, :id, :user_id, :address, :password, :encrypted_password, :encryption_key, :created_at, :updated_at
json.url emailaccount_url(emailaccount, format: :json)
