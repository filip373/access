class CalculateDiffStrategist
  WORKERS = [
    ::TogglWorkers::DiffWorker,
    ::GithubWorkers::DiffWorker,
    ::GoogleWorkers::DiffWorker,
    ::RollbarWorkers::TeamsWorker,
    ::JiraWorkers::DiffWorker,
  ].freeze
  private_constant :WORKERS

  attr_reader :controller, :label, :data_guru, :session_token

  def initialize(controller:, label:, data_guru:, session_token:)
    @controller = controller
    @label = label
    @data_guru = data_guru
    @session_token = session_token
  end

  def call
    diff_status = Rails.cache.fetch(diff_key_strategy)
    if diff_status.nil?
      data_guru.refresh
      worker_strategy.perform_later(session_token)
    elsif diff_status == false
      controller.redirect_to redirect_strategy
    end
  end

  private

  def diff_key_strategy
    case label
    when :toggl
      return 'toggl_performing_diff'
    when :github
      return 'github_performing_diff'
    when :rollbar
      return 'rollbar_performing_teams'
    when :google
      return 'google_performing_diff'
    when :jira
      return 'jira_performing_diff'
    end
  end

  def worker_strategy
    WORKERS.find { |worker| worker.applicable_to?(label) }
  end

  def redirect_strategy
    Rails.application.routes.url_helpers.public_send("#{label}_show_diff_path")
  end
end
