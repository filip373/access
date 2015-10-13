module TogglIntegration
  module Actions
    class Log
      def initialize(diff_hash)
        @diff_hash = diff_hash
        @log = []
      end

      def call
        generate_log
      end

      private

      def generate_log
        log_creating_teams
        log_inviting_members
        log_removing_members
        @log << 'There are no changes.' if @log.size == 0
        @log
      end

      def log_creating_teams
        @diff_hash[:create_teams].each do |team, members|
          @log << "[api] create team #{team.name}"
          members.each do |member|
            @log << "[api] add member #{member.emails.first} to team #{team.name}"
          end
        end
      end

      def log_inviting_members
        @diff_hash[:add_members].each do |team, members|
          members.each do |member|
            @log << "[api] add member #{member.emails.first} to team #{team.name}"
          end
        end
      end

      def log_removing_members
        @diff_hash[:remove_members].each do |team, members|
          members.each do |member|
            @log << "[api] remove member #{member.emails.first} from team #{team.name}"
          end
        end
      end
    end
  end
end
