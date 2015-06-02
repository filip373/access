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
        subscribe 'completed', :on_completion
      end

      def on_completion(_topic, diff_hash, errors)
        Rollbar.info("observer.on_completion", diff_hash: diff_hash, errors: errors)
        @diffed_count ||= 0
        @errors ||= []
        @diffed_count += 1
        @errors.push(*errors)
        @diff_hash.deep_merge!(diff_hash)
        Rollbar.info("observer.on_completion", diff_hash_merged: @diff_hash, errors_merged: @errors, diffed_count: @diffed_count)
        @condition.signal([@diff_hash, @errors]) if @diffed_count == @teams_count
      end
    end
  end
end