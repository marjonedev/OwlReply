class Reply < ApplicationRecord
  belongs_to :emailaccount

  def matches?(subject,body)
    content = ""
    content = "#{subject.downcase} #{body.downcase}" if self.search == "Subject and Body"
    content = "#{subject.downcase}" if self.search == "Subject Only"
    content = "#{body.downcase}" if self.search == "Body Only"
    for word in self.keywords.split(",")
      return true if word.downcase.in?(content)
    end
    return false
  end

  # THIS NEEDS TO BECOME A DB FIELD and added to the form with appropriate choices. Probably a select-field?
  # def search
  #   "Subject and Body"
  # end

end
