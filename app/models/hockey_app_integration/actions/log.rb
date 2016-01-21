module HockeyAppIntegration
  module Actions
    class Log
      attr_reader :diff_hash, :log

      def initialize(diff_hash)
        @diff_hash = diff_hash
        @log = []
      end

      def now!
        log_add_users
        log_remove_users
        log_add_teams
        log_remove_teams
        no_changes_in_log
      end

      private

      def no_changes_in_log
        log << 'There are no changes.' if log.size == 0
        log
      end

      def log_add_users
        Hash(diff_hash[:add_users]).each do |app, users|
          users.each do |u|
            log << "[appi] add user #{u} to app #{app.name}"
          end
        end
      end

      def log_remove_users
        Hash(diff_hash[:remove_users]).each do |app, users|
          users.each do |u|
            log << "[api] remove user #{u} from app #{app.name}"
          end
        end
      end

      def log_add_teams
        Hash(diff_hash[:add_teams]).each do |app, teams|
          teams.each do |t|
            log << "[api] add team #{t} to app #{app.name}"
          end
        end
      end

      def log_remove_teams
        Hash(diff_hash[:remove_teams]).each do |app, teams|
          teams.each do |t|
            log << "[api] remove team #{t} from app #{app.name}"
          end
        end
      end
    end
  end
end
