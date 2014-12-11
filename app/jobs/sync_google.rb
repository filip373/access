require Rails.root.join("app/models/actions/sync")
require Rails.root.join("app/models/google_integration/actions/sync_groups")
require Rails.root.join("app/models/slack_notification")

class SyncGoogleJob
  include SuckerPunch::Job

  def perform(api, diff)
    before
    Sync::Google.new(api).now!(diff)
    after
  end

  def before
    msg = "Synchronizing google groups..."
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
