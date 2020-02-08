module AdminHelper
  def users_per_day(days)
    User.where(created_at: days.days.ago..Date.today).group("DATE(created_at)").count
  end
end
