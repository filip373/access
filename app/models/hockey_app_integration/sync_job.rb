module HockeyAppIntegration
  class SyncJob
    def perform(api, diff)
      ping_messages { Actions::Sync.new(api, diff).now! }
    end

    private

    def ping_messages
      notification_ping! 'Synchronizing hockey apps...'
      yield
      notification_ping! 'Synchronization done! High Five!'
    end

    def notification_ping!(message)
      SlackNotification.new(message: message).ping!
    end
  end
end
