module GithubIntegration
  module Actions
    class Sync
      pattr_initialize :gh_api, :diff, :names_and_ids do
        @remove = diff.remove_hash
        @add = diff.add_hash
      end
      att_reader :remove, :add

      def now!
        add.each { |team_name, changes| sync_add_team(team_name.downcase, team_changes) }
        remove.each { |team_name, changes| sync_remove_team(team_name.downcase, team_changes) }
      end

      private

      def sync_add_team(team_name, team_changes)
        team_id = get_team_id(team_name)

        sync_add_members(team_id, team_changes[:members])
        sync_add_repos(team_id, team_changes[:repos])
        sync_add_permission(team_id, team_changes[:permission])
      end

      def sync_add_members(team_id, members)
        members.each { |member| gh_api.add_member(member, team_id) }
      end

      def sync_add_repos(team_id, repos)
        repos.each { |repo| gh_api.add_repo(repo, team_id) }
      end

      def sync_add_permission(team_id, permission)
        gh_api.add_permission(permission, team_id)
      end

      def sync_remove_team(team_name, team_changes)
        team_id = get_team_id(team_name)

        sync_remove_members(team_id, team_changes[:members])
        sync_remove_repos(team_id, team_changes[:repos])
        sync_remove_permission(team_id, team_changes[:permission])
      end

      def sync_remove_members(team_id, members)
        members.each { |member| gh_api.remove_member(member, team_id) }
      end

      def sync_remove_repos(team_id, repos)
        repos.each { |repo| gh_api.remove_repo(repo, team_id) }
      end

      def get_team_id(team_name)
        team_id = names_and_ids[team_name]
        team_id || create_team(team_name)
      end

      def create_team(team_name)
        team = gh_api.create_team(name: team_name, permission: default_permission)
        names_and_ids[team['name']] = team['id']
        team['id']
      end

      def default_permission
        # This will be replaced after DataGuru::Configuration exposes default values for attributes
        'push'
      end
    end
  end
end
