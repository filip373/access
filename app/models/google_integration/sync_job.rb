module GoogleIntegration
  class SyncJob
    include SuckerPunch::Job

    def perform(api, diff)
      before
      GoogleIntegration::Actions::Sync.new(api).now!(diff)
      after
    end

    def before
      msg = 'Synchronizing google groups...'
      notification_ping! msg
    end

    def after
      msg = 'Synchronization done! High Five!'
      notification_ping! msg
    end

    def notification_ping!(_msg)
      notifier = SlackNotification.new(message: msg)
      notifier.ping!
    end
  end
end
