class Reply < ApplicationRecord
  belongs_to :emailaccount
  include Stopwords

  def matches?(subject,body)
    content = ""
    content = "#{subject.downcase} #{body.downcase}" if self.search == "Subject and Body" || self.search.nil?
    content = "#{subject.downcase}" if self.search == "Subject Only"
    content = "#{body.downcase}" if self.search == "Body Only"
    for word in self.keywords.split(",")
      return true if word.downcase.in?(content)
    end
    return false
  end

  def self.suggest_keywords(text)
    text = text.uniq.map{|word|word.downcase.gsub(/[^0-9a-z ]/i, '')}.uniq
    words = text.select{|word|
      !word.in?(Stopwords.words)
    }
    words.delete_if do |word|
      (word.match(/[^a-zA-Z0-9]*$/).nil?) || (word.include?('http') || word.include?('@') || word.include?('$') || (word.length<5))
    end
    words.sort!
    return words
  end

  # THIS NEEDS TO BECOME A DB FIELD and added to the form with appropriate choices. Probably a select-field?
  # def search
  #   "Subject and Body"
  # end

end
