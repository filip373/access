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
        @diff_hash[:create_teams].each do |team, h|
          @log << "[api] create team #{team.name}"

          if h[:add_members].present?
            h[:add_members].each do |email, _m|
              @log << "[api] add member #{email} to team #{team.name}"
            end
          end

          if h[:add_projects].present?
            h[:add_projects].each do |name, _r|
              @log << "[api] add project #{name} to team #{team.name}"
            end
          end
        end
      end

      def log_inviting_members
        @diff_hash[:add_members].each do |team, members|
          members.each do |email, _m|
            @log << "[api] add member #{email} to team #{team.name}"
          end
        end
      end

      def log_removing_members
        @diff_hash[:remove_members].each do |team, members|
          members.each do |email, _m|
            @log << "[api] remove member #{email} from team #{team.name}"
          end
        end
      end
    end
  end
end
