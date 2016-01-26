class HockeyAppPresenter
  attr_reader :diff, :data_guru

  def initialize(diff, data_guru)
    @diff = diff
    @data_guru = data_guru
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
end
