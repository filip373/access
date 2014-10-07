module GithubIntegration
  class Teams

    def self.all
      @@all ||= data
    end

    def self.data
      @@data ||=  raw_data.map do |team_name, team_data|
        Team.new(
          team_name,
          team_data.members,
          team_data.repos,
          team_data.premission || default_permission
        )
      end
    end

    private

    def self.raw_data
      Storage.data.github_teams
    end

    def self.teams_repo_path
      "#{Rails.root}/tmp/permissions/github_teams"
    end

    def self.default_permission
      'push'
    end
  end

  class Team < Struct.new(:name, :members, :repos, :permission)
  end

end
