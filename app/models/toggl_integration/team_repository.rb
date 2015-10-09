module TogglIntegration
  class TeamRepository
    attr_accessor :all

    def initialize(all: [])
      self.all = all
    end

    def self.build_from_data_guru(dg_client)
      teams = dg_client.toggl_teams.map do |team|
        Team.new(team.name, team.members, team.projects)
      end
      new(all: teams)
    end

    def self.build_from_toggl_api(toggl_api, user_repository)
      teams = toggl_api.list_teams.map do |team|
        Team.new(team['name'],
                 team_members(toggl_api, team, user_repository),
                 [team['name']],
                 team['id'],
                )
      end
      new(all: teams)
    end

    def self.team_members(api, team, user_repo)
      api.list_team_members(team['id']).map do |member|
        begin
          user_repo.find_by_email(member['email']).id
        rescue
          nil
        end
      end.compact
    end

    def self.team_projects(team)
      [team['name']]
    end

    private_class_method :team_members, :team_projects
  end
end
