json.extract! invoice, :id, :user_id, :amount, :amount_paid, :date_paid, :transaction_id, :created_at, :updated_at
json.url invoice_url(invoice, format: :json)
