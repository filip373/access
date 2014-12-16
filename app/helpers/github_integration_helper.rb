module GithubIntegrationHelper

  def github_team_path(team_name)
    "https://github.com/orgs/#{AppConfig.company}/teams/#{team_name}"
  end

  def github_file_path(file)
    "#{AppConfig.permissions_repo.url}/blob/master/#{file}"
  end
end
