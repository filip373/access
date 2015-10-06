module RollbarIntegration
  class Team
    rattr_initialize :name, :members, :projects
    attr_accessor :id

    def self.from_api_request(api, team)
      new(
        team.name,
        prepare_members(api, team),
        api.list_team_projects(team.id).map(&:name).uniq.compact,
      )
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
