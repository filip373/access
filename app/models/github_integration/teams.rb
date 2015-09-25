module GithubIntegration
  class Teams
    def self.all
      raw_data.map do |team|
        Team.new(
          team.id,
          team.members,
          team.repos,
          team.permission,
        )
      end
    end

    def self.raw_data
      DataGuru::Client.new.github_teams
    end
  end
end
