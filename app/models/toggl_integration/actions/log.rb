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
        log_add_members
        log_deactivate_members
        @log << 'There are no changes.' if @log.size == 0
        @log
      end

      def log_creating_teams
        @diff_hash[:create_teams].each do |team, members|
          @log << "[api] create team #{team.name}"
          members.each do |member|
            log_add_or_invite_member(member, team)
          end
        end
      end

      def log_add_members
        @diff_hash[:add_members].each do |team, members|
          members.each do |member|
            log_add_or_invite_member(member, team)
          end
        end
      end

      def log_deactivate_members
        @diff_hash[:deactivate_members].each do |member|
          @log << "[api] deactivate member #{member.emails.first}"
        end
      end

      def log_add_or_invite_member(member, team)
        @log << if member.toggl_id?
                  "[api] add member #{member.default_email} to team #{team.name}"
                else
                  "[api] invite member #{member.default_email} to team #{team.name}"
        end
      end
    end
  end
end
