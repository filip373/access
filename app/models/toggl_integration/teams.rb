module TogglIntegration
  class Teams
    def self.all
      raw_data.map do |team|
        Team.new(team.name, team.members, team.projects)
      end
    end

    def self.raw_data
      DataGuru::Client.new.toggl_teams
    end

    private_class_method :raw_data
  end
end
