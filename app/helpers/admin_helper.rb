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

  def late_invoices
    Invoice.where('(amount_paid IS NULL OR amount_paid = "") OR (date_paid IS NULL OR date_paid = "")').count
  end

  def daily_revenue
    sum = Invoice.where('amount_paid IS NOT NULL AND amount_paid <> ""')
        .where('date_paid IS NOT NULL AND date_paid <> ""')
        .where(date_paid: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day)
        .sum(:amount_paid)

    "$#{sum / 100}"
  end

  def monthly_revenue
    sum = Invoice.where('amount_paid IS NOT NULL AND amount_paid <> ""')
        .where('date_paid IS NOT NULL AND date_paid <> ""')
        .where('extract(month from date_paid) = ?', Time.now.month)
        .sum(:amount_paid)

    "$#{sum / 100}"
  end
end
