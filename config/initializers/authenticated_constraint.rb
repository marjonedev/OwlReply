class AuthenticatedConstraint
  def initialize(domain)
    @domains = [domain].flatten
    @anime = Animanga.shows
  end

  def matches?(request)
    !current_user.nil?
    #Rails.logger.info request.path.split("/").second if @domains.include? request.host
    #(@domains.include? request.host) && (@anime.include?(request.path.split("/").second))#(@anime.include?(request.path.gsub("/","")))
  end
end