class AuthenticatedConstraint
  def initialize
  end

  def matches?(request)
    !current_user.nil?
  end
end