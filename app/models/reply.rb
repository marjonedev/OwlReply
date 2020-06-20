class Reply < ApplicationRecord
  belongs_to :emailaccount
  include Stopwords

  def matches?(subject,body)
    subject = subject.to_s.downcase
    body = body.to_s.downcase
    content = ""
    content = "#{subject} #{body}" if self.search == "Subject and Body" || self.search.nil?
    content = "#{subject}" if self.search == "Subject Only"
    content = "#{body}" if self.search == "Body Only"
    for word in self.keywords.split(",")
      return true if word.to_s.downcase.in?(content)
    end
    return false
  end

  def self.suggest_keywords(text, user_id: nil)
    text = text.uniq.map{|word|word.downcase.gsub(/[^0-9a-z ]/i, '')}.uniq
    words = text.select{|word|
      !word.in?(Stopwords.words)
    }
    if !user_id.nil?
      user = User.find(user_id)
      words = words.select{|word|
        !word.in?(user.ignoredwords.map{|w| w.word })
      }
    end
    words.delete_if do |word|
      (word.match(/[^a-zA-Z0-9]*$/).nil?) || (word.include?('http') || word.include?('@') || word.include?('$') || (word.length<5))
    end
    words.sort!
    return words
  end

  def self.selected(emailaccount, word)
    !emailaccount.replies.select{|e| e.keywords.split(',').include?(word) rescue nil }.empty?
  end

  # THIS NEEDS TO BECOME A DB FIELD and added to the form with appropriate choices. Probably a select-field?
  # def search
  #   "Subject and Body"
  # end

end
