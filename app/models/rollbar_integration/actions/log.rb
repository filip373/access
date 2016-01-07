module RollbarIntegration
  module Actions
    class Log
      def initialize(diff_hash)
        @diff_hash = diff_hash
        @log = []
      end

      def now!
        generate_log
      end

      private

      def generate_log
        log_creating_teams
        log_inviting_members
        log_removing_members
        log_adding_projects
        log_removing_projects
        log_no_changes
      end

      def log_no_changes
        @log << 'There are no changes.' if @log.size == 0
        @log
      end

      def log_creating_teams
        @diff_hash[:create_teams].each do |team, h|
          message_create_team(team)
          message_add_members(team, h)
          message_add_projects(team, h)
        end
      end

      def message_create_team(team)
        @log << "[api] create team #{team.name}"
      end

      def message_add_members(team, h)
        return unless h[:add_members].present?
        h[:add_members].each do |email, _m|
          @log << "[api] add member #{email} to team #{team.name}"
        end
      end

      def message_add_projects(team, h)
        return unless h[:add_projects].present?
        h[:add_projects].each do |name, _r|
          @log << "[api] add project #{name} to team #{team.name}"
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

      def log_adding_projects
        @diff_hash[:add_projects].each do |team, projects|
          projects.each do |name, _r|
            @log << "[api] add project #{name} to team #{team.name}"
          end
        end
      end

      def log_removing_projects
        @diff_hash[:remove_projects].each do |team, projects|
          projects.each do |name, _r|
            @log << "[api] remove project #{name} from team #{team.name}"
          end
        end
      end
    end
  end
end
