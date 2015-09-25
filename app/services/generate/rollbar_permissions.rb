module Generate
  class RollbarPermissions
    pattr_initialize :rollbar_api, :permissions_dir

    def call
      recreate_rollbar_dir

      teams.each do |team|
        File.open(rollbar_dir.join("#{team.name}.yml"), 'w') do |f|
          f.write team.to_yaml
        end
      end
    end

    private

    def teams
      rollbar_api.list_teams.map do |team|
        RollbarIntegration::Team.from_api_request(rollbar_api, team)
      end
    end

    def rollbar_dir
      permissions_dir.join 'rollbar_teams'
    end

    def recreate_rollbar_dir
      FileUtils.rm_rf(rollbar_dir)
      FileUtils.mkdir_p(rollbar_dir)
    end
  end
end
