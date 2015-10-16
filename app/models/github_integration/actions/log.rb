module GithubIntegration
  module Actions
    class Log
      attr_reader :diff
      def initialize(diff)
        @diff = diff.show_by_team
      end

      def now!
        log = diff.flat_map { |team_name, changes| TeamLog.new(team_name, changes).now! }
        log << 'There are no changes.' if log.empty?
        log
      end
    end
  end
end
