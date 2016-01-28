class HockeyAppFacade
  attr_reader :diff, :data_guru, :user_repo

  def initialize(diff, data_guru, user_repo)
    @diff = diff
    @data_guru = data_guru
    @user_repo = user_repo
  end

  def missing_api_apps
    diff[:missing_api_apps]
  end

  def missing_dg_apps
    diff[:missing_dg_apps]
  end

  def log
    HockeyAppIntegration::Actions::Log.new(diff).now!
  end

  def validation_errors
    data_guru.errors
  end

  def repo_errors
    Rails.cache.fetch('hockeyapp_repo_errors') do
      user_repo.errors.uniq
    end
  end
end
