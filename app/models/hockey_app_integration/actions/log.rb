module HockeyAppIntegration
  module Actions
    class Log
      attr_reader :diff_hash, :log

      def initialize(diff_hash)
        @diff_hash = diff_hash
        @log = []
      end

      def now!
        log_resources(:add_users)
        log_resources(:remove_users)
        log_resources(:add_teams)
        log_resources(:remove_teams)
        no_changes_in_log
      end

      private

      def no_changes_in_log
        log << 'There are no changes.' if log.size == 0
        log
      end

      def log_resources(label)
        Hash(diff_hash[label]).each do |app, collection|
          collection.each do |item|
            log << find_message(label, item, app.name)
          end
        end
      end

      def find_message(label, item, app_name)
        case label
        when :add_users
          user_name = item.last.first.name
          return "[api] add user #{user_name} (group: #{item.first}) to app #{app_name}"
        when :remove_users
          user_name = item.last.first.name
          return "[api] remove user #{user_name} (group: #{item.first}) from app #{app_name}"
        when :add_teams
          return "[api] add team #{item} to app #{app_name}"
        when :remove_teams
          return "[api] remove team #{item} from app #{app_name}"
        end
      end
    end
  end
end
