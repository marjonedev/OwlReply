class PagesController < ApplicationController
  def home
    if current_user
      if current_user.admin
        render file: "admin/dashboard"
      else
        @emailaccounts = current_user.emailaccounts
        if @emailaccounts.count == 1
          @emailaccount = @emailaccounts.first
          @replies = @emailaccount.replies.order("created_at DESC")
          render file: "emailaccounts/show"
        else
          render file: "emailaccounts/index"
        end
      end
    else

    end
  end
  
  def help
  end

  def features
  end

  def pricing
    @plans = Subscription.all
  end

  def signup
  end

  def documentation
  end

  def faqs
  end

  def security
  end

  def terms
  end

  def privacy
  end

  def guide_email_automation
    @page_title = "A guide to automating your email replies from OwlReply."
    render file: 'pages/guides/email_automation'
  end
  def guide_customer_service_emails
    @page_title = "Writing better customer service emails. | OwlReply"
    render file: 'pages/guides/customer_service_emails'
  end
  def guide_tips_for_good_emails
    @page_title = "A guide to writing better emails. - OwlReply"
    render file: 'pages/guides/tips_for_good_emails'
  end
end

