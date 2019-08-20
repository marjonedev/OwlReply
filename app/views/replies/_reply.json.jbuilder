json.extract! reply, :id, :keywords, :body, :negative_keywords, :catchcall, :created_at, :updated_at
json.url reply_url(reply, format: :json)
