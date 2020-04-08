class Wordcount < ApplicationRecord
  belongs_to :emailaccount
  include ActionView::Helpers::SanitizeHelper

  def self.up(account,word)
    c = Wordcount.find_or_create_by(emailaccount_id: account.id, word: word)
    c.increment!(:count)
  end

  def self.count(account,body)
    return if body.length < 100
    body = Wordcount.new.strip_tags(body)
    words = body.split(/\s+/)
    words = Reply.suggest_keywords(words)
    for word in words
      up(account,word)
    end
  end

end
