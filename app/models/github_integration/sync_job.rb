module GithubIntegration
  class SyncJob
    def perform(api, diff)
      ping_messages { GithubIntegration::Actions::Sync.new(api).now!(diff) }
    end

    private

    def ping_messages
      notification_ping! 'Synchronizing github teams...'
      yield
      notification_ping! 'Synchronization done! High Five!'
    end

    def notification_ping!(msg)
      notifier = SlackNotification.new(message: msg)
      notifier.ping!
    end
  end
end
