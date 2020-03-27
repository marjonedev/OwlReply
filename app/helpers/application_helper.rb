module ApplicationHelper
  def show_field_error(model, field)
    s=""

    if !model.errors[field].empty?
      s =
          <<-EOHTML
           <div id="error_message">
             #{model.errors[field][0]}
           </div>
      EOHTML
    end

    s.html_safe
  end

  def number_of_accounts
    User.where(:admin => false).count
  end

  def number_of_email_accounts
    Emailaccount.left_joins(:user).where(users: {admin: false}).count
  end

  def number_of_replies
    Reply.count
  end

  def total_drafts_created_today
    Emailaccount.sum(:drafts_created_today)
  end

  def total_drafts_created_lifetime
    Emailaccount.sum(:drafts_created_lifetime)
  end

  def total_signups_today
    User.where(:created_at => (Time.zone.now.beginning_of_day..Time.zone.now.end_of_day)).count
  end

  def total_subscribers
    User.joins(:subscription).where('subscriptions.price > 0').count
  end

  def html_attr_selected data = nil, value = nil
    if !data.nil? and !value.nil?
      if data.to_s === value.to_s
        return 'selected=selected'
      end
    end
    "#{data} - #{value}"
  end

  def is_valid_url? url
    require 'uri'
    uri = URI.parse(url)
    uri.is_a?(URI::HTTP) && !uri.host.nil?
  rescue URI::InvalidURIError
    false
  end

end
