class PagesController < ApplicationController
  def home
    if current_user
      @emailaccounts = current_user.emailaccounts
      render file: "emailaccounts/index"
    else

    end
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

