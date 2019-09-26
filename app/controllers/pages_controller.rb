class PagesController < ApplicationController
  def home
    if current_user
      if current_user.admin
        render file: "admin/dashboard"
      else
        @emailaccounts = current_user.emailaccounts
        render file: "emailaccounts/index"
      end
    else

    end
  end
  
  def help
  end

  def features
  end

  def pricing
  end

  def signup
  end

  def documentation
  end

  def faqs
  end

  def security
  end
end

