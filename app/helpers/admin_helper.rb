module AdminHelper
  def users_per_day(days)
    User.where(created_at: days.days.ago..Date.today).group("DATE(created_at)").count
  end

  def users_subscribed(days)
    User.where(subscription_start_date: days.days.ago..Date.today).group("DATE(subscription_start_date)").count
  end

  def users_referer(days)
    users = User.where(created_at: days.days.ago..Date.today)
    obj = {}

    users.each do |user|
      unless user.referer.to_s.blank?
        if is_valid_url? user.referer.to_s
          url = Addressable::URI.parse(user.referer.to_s).host
          obj[url] =  obj[url].to_i + 1
        end
      end
    end

    obj

  end

  def reply_maker_process_size
    processes = `ps aux | grep -i rails`.to_s

    processes.scan(/reply/).size
  end
end
