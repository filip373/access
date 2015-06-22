module Generate
  class GithubPermissions
    pattr_initialize :github_api, :permissions_dir

    def call
      recreate_github_dir

      teams.each do |team|
        File.open(github_dir.join("#{team.name}.yml"), 'w') do |f|
          f.write team.to_yaml
        end
      end
    end

    private

    def teams
      @teams ||= github_api.list_teams.map do |team|
        GithubIntegration::Team.from_api_request(github_api, team)
      end
    end

    def github_dir
      permissions_dir.join 'github_teams'
    end

    def recreate_github_dir
      FileUtils.rm_rf(github_dir)
      FileUtils.mkdir_p(github_dir)
    end
  end
end
