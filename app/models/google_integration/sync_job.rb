module GoogleIntegration
  class SyncJob
    def perform(api, diff)
      ping_messages { GoogleIntegration::Actions::Sync.new(api).now!(diff) }
    end

    private

    def ping_messages
      notification_ping! "Synchronizing google groups..."
      yield
      notification_ping! "Synchronization done! High Five!"
    end

    def notification_ping!(msg)
      notifier = SlackNotification.new(message: msg)
      notifier.ping!
    end
  end
end
