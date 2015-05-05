module GithubIntegration
  class SyncJob
    include SuckerPunch::Job

    def perform(api, diff)
      before
      GithubIntegration::Actions::Sync.new(api).now!(diff)
      after
    end

    def before
      msg = 'Synchronizing github teams...'
      notification_ping! msg
    end

    def after
      msg = 'Synchronization done! High Five!'
      notification_ping! msg
    end

    def notification_ping!(msg)
      notifier = SlackNotification.new(message: msg)
      notifier.ping!
    end
  end
end
