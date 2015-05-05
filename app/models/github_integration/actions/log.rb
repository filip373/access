module GithubIntegration
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
        log_adding_members
        log_removing_members
        log_adding_repos
        log_removing_repos
        log_changing_permissions
        @log << 'There are no changes.' if @log.size == 0
        @log
      end

      def log_creating_teams
        @diff_hash[:create_teams].each do |team, h|
          @log << "[api] create team #{team.name}"

          h[:add_members].each do |m|
            @log << "[api] add member #{m} to team #{team.name}"
          end

          h[:add_repos].each do |r|
            @log << "[api] add repo #{r} to team #{team.name}"
          end

          unless h[:add_permissions].empty?
            @log << "[api] add permissions #{team.name} - #{h[:add_permissions]}"
          end
        end
      end

      def log_changing_permissions
        @diff_hash[:change_permissions].each do |team, permissions|
          @log << "[api] change permissions #{team.name} - #{permissions}"
        end
      end

      def log_adding_members
        @diff_hash[:add_members].each do |team, members|
          members.each do |m|
            @log << "[api] add member #{m} to team #{team.name}"
          end
        end
      end

      def log_removing_members
        @diff_hash[:remove_members].each do |team, members|
          members.each do |m|
            @log << "[api] remove member #{m} from team #{team.name}"
          end
        end
      end

      def log_adding_repos
        @diff_hash[:add_repos].each do |team, repos|
          repos.each do |r|
            @log << "[api] add repo #{r} to team #{team.name}"
          end
        end
      end

      def log_removing_repos
        @diff_hash[:remove_repos].each do |team, repos|
          repos.each do |r|
            @log << "[api] remove repo #{r} from team #{team.name}"
          end
        end
      end
    end
  end
end
