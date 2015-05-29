require 'celluloid/autostart'

module GithubIntegration
  module Observers
    class TeamDiffObserver
      include Celluloid
      include Celluloid::Notifications

      def initialize(condition, teams_count)
        @condition = condition
        @teams_count = teams_count
        
        @diff_hash = {
          create_teams: {},
          add_members: {},
          remove_members: {},
          add_repos: {},
          remove_repos: {},
          change_permissions: {},
        }
      end

      def on_completion(_topic, diff_hash, errors)
        @diffed_count ||= 0
        @errors ||= []
        @diffed_count += 1
        @errors.push(*errors)
        @diff_hash.deep_merge!(diff_hash)
        @condition.signal([@diff_hash, @errors]) if @diffed_count == @teams_count
      end
    end
  end
end