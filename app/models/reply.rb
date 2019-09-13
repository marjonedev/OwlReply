class Reply < ApplicationRecord
  belongs_to :emailaccount

  def matches?(subject,body)
    content = ""
    content = "#{subject} #{body}" if self.search == "Subject and Body"
    content = "#{subject}" if self.search == "Subject Only"
    content = "#{body}" if self.search == "Body Only"
    for word in self.keywords.split(",")
      return true if word.in?(content)
    end
    return false
  end

  def search
    "Subject and Body"
  end

end
