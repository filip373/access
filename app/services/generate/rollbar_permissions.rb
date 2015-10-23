module Generate
  class RollbarPermissions
    pattr_initialize :rollbar_api, :permissions_dir, :user_repo

    def call
      recreate_rollbar_dir

      teams.each do |team|
        File.open(rollbar_dir.join("#{file_name(team.name)}.yml"), 'w') do |f|
          f.write team.to_yaml
        end
      end
    end

    private

    def teams
      rollbar_api.list_teams.map do |team|
        RollbarIntegration::Team.from_api_request(rollbar_api, team, user_repo)
      end
    end

    def rollbar_dir
      permissions_dir.join 'rollbar_teams'
    end

    def file_name(team_name)
      team_name = File.basename(team_name.tr('\\', '/'))
      team_name.gsub!(/[^a-zA-Z0-9\.\-\+_]/, '_')
      team_name = "_#{team_name}" if team_name =~ /^\.+$/
      team_name
    end

    def recreate_rollbar_dir
      FileUtils.rm_rf(rollbar_dir)
      FileUtils.mkdir_p(rollbar_dir)
    end
  end
end
