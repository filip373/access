module GithubIntegration
  class SyncJob
    def perform(api, diff, gh_teams)
      ping_messages { GithubIntegration::Actions::Sync.new(api, diff, gh_teams_names_and_ids).now! }
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
