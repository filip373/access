module GoogleHelper
  def user_mail user
    "#{user}@#{AppConfig.email_domain}"
  end
end
