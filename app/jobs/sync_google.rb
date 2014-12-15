require Rails.root.join("app/models/slack_notification")

module Jobs
  class SyncGoogleJob
    include SuckerPunch::Job

    def perform(api, diff)
      before
      GoogleIntegration::Actions::Sync.new(api).now!(diff)
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
end
