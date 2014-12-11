require Rails.root.join("app/models/actions/sync")
require Rails.root.join("app/models/github_integration/actions/sync_teams")
require Rails.root.join("app/models/slack_notification")

class SyncGithubJob
  include SuckerPunch::Job

  def perform(api, diff)
    before
    Sync::Github.new(api).now!(diff)
    after
  end

  def before
    msg = "Synchronizing github teams..."
    notification_ping! msg
  end

  def after
    msg = "Synchronization done! High Five!"
    notification_ping! msg
  end

  def notification_ping! msg
    notifier = SlackNotification.new(ENV['SLACK_TOKEN'], ENV['SLACK_CHANNEL'], ENV['REVIEW_PATH'], ENV['APP_URL'], message: msg)
    notifier.ping!
  end
end
