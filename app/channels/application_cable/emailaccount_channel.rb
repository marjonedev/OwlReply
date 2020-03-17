include ActionView::Helpers::DateHelper

class EmailaccountChannel < ApplicationCable::Channel
  def subscribed
    account = Emailaccount.find(params[:id])
    stream_for account
    # stream_from "emailaccount_#{account.id}_channel"
    send_last_check account
  end
  def unsubscribed
  end
  def receive(data)
    if data['something']
      # Do Thing.
    end
  end

  def send_last_check account

    last_checked = account.last_checked.to_i ? time_ago_in_words(account.last_checked.to_i).humanize : ""
    data = {last_checked: "Last checked: #{last_checked} ago"}

    EmailaccountChannel.broadcast_to(account, data)
  end
end