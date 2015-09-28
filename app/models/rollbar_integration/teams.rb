module RollbarIntegration
  class Teams
    def self.all
      raw_data.map do |_team_name, team_data|
        Team.new(
          team_data.name,
          team_data.members || [],
          team_data.projects || [],
        )
      end
    end

    def self.raw_data
      Storage.data.rollbar_teams || []
    end

    def self.teams_repo_path
      "#{Rails.root}/tmp/permissions/rollbar_teams"
    end
  end
end
