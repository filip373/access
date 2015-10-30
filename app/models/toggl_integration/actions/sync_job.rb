module TogglIntegration
  module Actions
    class SyncJob
      pattr_initialize :diffs, :toggl_api

      def call
        before
        TogglIntegration::Actions::Sync.new(diffs, toggl_api).call
        after
      end

      private

      def before
        msg = 'Synchronizing toggl teams...'
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
end
