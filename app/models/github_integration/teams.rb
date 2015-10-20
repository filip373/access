module GithubIntegration
  class Teams
    def self.all(raw_data)
      raw_data.map do |team|
        Team.new(
          team.id,
          team.members,
          team.repos,
          team.permission,
        )
      end
    end
  end
end
