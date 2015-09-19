module RollbarIntegration
  class Team
    rattr_initialize :name, :members, :projects

    def self.from_api_request(api, team)
      new(
        team.name,
        prepare_members(api, team),
        api.list_team_projects(team.id).map(&:name).uniq,
      )
    end

    def to_yaml
      {
        members: members || [],
        projects: projects || [],
      }.stringify_keys.to_yaml
    end

    def self.prepare_members(api, team)
      usernames = api.list_team_members(team.id).map(&:username)
      usernames.map do |username|
        begin
          user = User.find_by_rollbar(username).name
        rescue
          Rollbar.info("There is no user with rollbar: #{username}")
          user = nil
        end
        user
      end.compact
    end
  end
end
