module GithubApi
  extend ActiveSupport::Concern
  
  def gh_api
    GithubIntegration::Api.new(session[:gh_token], AppConfig.company)
  end
end