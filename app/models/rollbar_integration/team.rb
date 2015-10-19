module RollbarIntegration
  class Team
    rattr_initialize :name, :members, :projects
    attr_accessor :id

    def self.from_api_request(api, team)
      t = new(
        team.name,
        prepare_members(api, team),
        api.list_team_projects(team.id).map(&:name).uniq.compact,
      )
      t.id = team['id']
      t
    end

    def self.from_dataguru(dg_team)
      new(
        dg_team.id,
        dg_team.members,
        dg_team.projects
      )
    end

    def self.all_from_dataguru(dg_teams)
      dg_teams.map do |dg_team|
        from_dataguru(dg_team)
      end
    end

    def self.all_from_api(rollbar_api)
      rollbar_api.list_teams.map do |team|
        from_api_request(rollbar_api, team)
      end
    end

    def to_yaml
      {
        name: name,
        members: members || [],
        projects: projects || [],
      }.stringify_keys.to_yaml
    end

    def self.prepare_members(api, team)
      api.list_all_team_members(team.id).map do |rollbar_user|
        begin
          user = UserRepository.new.find_by_email(rollbar_user.email).id
        rescue
          Rollbar.info("There is no user with email: #{rollbar_user.email}")
        end
        user
      end.compact
    end
  end
end
