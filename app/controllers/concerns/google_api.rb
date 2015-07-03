module GoogleApi
  extend ActiveSupport::Concern

  included do
    rescue_from ArgumentError, with: :google_error
    rescue_from GoogleIntegration::ApiError, with: :suggest_relogin
    before_filter :google_auth_required, unless: :google_logged_in?
    before_filter :unauthorized_access, unless: :google_authorized?
  end

  def google_api
    @google_api ||= GoogleIntegration::Api.new(
      session[:credentials],
      authorization: google_authorization
    )
  end

  def google_authorized?(authorization: GoogleIntegration::Api::UserAccountAuthorization)
    return true unless AppConfig.features.use_service_account?
    credentials = session[:credentials]

    return false if credentials.nil?
    return true if permitted_members.empty?

    user_email = authorization.new(
      credentials: credentials
    ).email
    username = GoogleIntegration::Helpers::User.email_to_username(user_email)

    permitted_members.include? username
  end

  def unauthorized_access
    flash[:danger] = "Unauthorized access!"
    redirect_to root_url
  end

  def google_logged_in?
    session[:credentials].present?
  end

  def google_auth_required
    redirect_to '/auth/google_oauth2'
  end

  def google_error(e)
    if signet_errors.include? e.message
      google_auth_required
    else
      fail
    end
  end

  def suggest_relogin(e)
    flash[:api_error] = "We've encountered a problem with API: `#{e}`."
    redirect_to root_url
  end

  def signet_errors
    [
      'Missing required redirect URI.',
      'Missing token endpoint URI.',
      'Missing authorization code.',
      'Missing access token.',
    ]
  end

  def permitted_members
    return [] unless AppConfig.google.managers?

    group_managers = Array(AppConfig.google.managers.groups)
    group_managers.map do |group_name|
      GoogleIntegration::Groups.find_by(name: group_name).try(:members) || []
    end.flatten.uniq
  end

  def google_authorization
    if AppConfig.features.use_service_account?
      GoogleIntegration::Api::ServiceAccountAuthorization
    else
      GoogleIntegration::Api::UserAccountAuthorization
    end
  end
end
