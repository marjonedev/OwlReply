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

end
