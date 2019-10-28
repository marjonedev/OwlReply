module EmailaccountsHelper
  include ActionView::Helpers::DateHelper
  def last_checked_at(obj)
     if obj.error
       return "Last error: #{obj.error}"
     end
     unless obj.last_checked.nil?
       return "Last checked: #{time_ago_in_words obj.last_checked} ago"
     end
  end

  def number_of_keywords(emailaccount)
    count = 0
    for reply in emailaccount.replies
      count += reply.keywords.split(",").count
    end

    "#{count} keywords"
  end

  def is_main_account(emailaccount)
    current_user.email_address == emailaccount.address
  end
end
