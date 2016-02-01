module JiraIntegration
  class SyncJob
    def perform(api, diff)
      ping_messages { Actions::Sync.call(diff, api) }
    end

    private

    def ping_messages
      notification_ping! 'Synchronizing JIRA teams...'
      response = yield
      notification_ping! 'Synchronization done! High Five!'
      response
    end

    def notification_ping!(msg)
      notifier = SlackNotification.new(message: msg)
      notifier.ping!
    end
  end
end
