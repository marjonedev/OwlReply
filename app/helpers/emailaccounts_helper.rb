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
end
