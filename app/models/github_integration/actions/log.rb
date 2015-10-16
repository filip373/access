module GithubIntegration
  module Actions
    class Log
      attr_reader :diff, :log
      def initialize(diff)
        @log = []
        @diff = diff.show_by_team
      end

      def now!
        generate_log
      end

      private

      def generate_log
        diff.each { |team_name, changes| log_team(team_name, changes) }
        log << 'There are no changes.' if log.empty?
        log
      end

      def log_team(team_name, changes)
        log_adding(team_name, changes[:add])
        log_removing(team_name, changes[:remove])
      end

      def log_adding(team_name, changes)
        log_adding_members(team_name, changes[:members])
        log_adding_repos(team_name, changes[:repos])
        log_changing_permissions(team_name, changes[:permission])
      end

      def log_removing(team_name, changes)
        log_removing_members(team_name, changes[:members])
        log_removing_repos(team_name, changes[:repos])
      end

      def log_changing_permissions(team_name, permission)
        log << "[gh] change permissions #{team_name} - #{permission}"
      end

      def log_adding_members(team_name, members)
        members.each { |m| log << "[gh] add member #{m} to team #{team_name}" }
      end

      def log_removing_members(team_name, members)
        members.each { |m| log << "[gh] remove member #{m} from team #{team_name}" }
      end

      def log_adding_repos(team_name, repos)
        repos.each { |r| log << "[gh] add repo #{r} to team #{team_name}" }
      end

      def log_removing_repos(team_name, repos)
        repos.each { |r| log << "[gh] remove repo #{r} from team #{team_name}" }
      end
    end
  end
end
