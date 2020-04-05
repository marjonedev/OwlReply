class Reply < ApplicationRecord
  belongs_to :emailaccount

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
    words = text.select{|word|
      word = word.downcase
      !word.in?(Stopwords::Stopwords.words)
    }
    return text.join(" ")
  end

  # THIS NEEDS TO BECOME A DB FIELD and added to the form with appropriate choices. Probably a select-field?
  # def search
  #   "Subject and Body"
  # end

end
