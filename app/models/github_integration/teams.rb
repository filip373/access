module GithubIntegration
  class Teams
    def self.all_from_storage(raw_data)
      raw_data.map { |team| Team.from_storage(team) }
    end

    def self.all_from_api(client, gh_teams)
      gh_teams.map { |team| Team.from_api_request(client, team) }
    end

    def self.names_and_ids(gh_teams)
      gh_teams.each_with_object({}) { |team, hash| hash[team.name.downcase] = team.id }
    end
  end
end
