module GoogleIntegration
  class GenerateController < GoogleIntegration::BaseController
    before_filter :google_auth_required, unless: :google_logged_in?
    rescue_from ArgumentError, with: :google_error

    def permissions
      Generate::GooglePermissions.new(
        api_groups,
        permissions_dir,
      ).call

      flash[:notice] = 'Permissions has been created'

      redirect_to '/'
    end

    def permissions_dir
      Rails.root.join('tmp/new_permissions/')
    end

    def api_groups
      Rails.cache.fetch 'api_groups' do
        google_api = Api.new(session[:credentials])
        google_api.list_groups_full_info
      end
    end
  end
end
