module Generate
  class TogglPermissions
    pattr_initialize :toggl_api, :permissions_dir

    def call
      recreate_toggl_dir

      teams.each do |team|
        File.open(toggl_dir.join("#{file_name(team.name)}.yml"), 'w') do |f|
          f.write team.to_yaml
        end
      end
    end

    private

    def teams
      toggl_api.list_teams.map do |team|
        TogglIntegration::Team.from_api_request(toggl_api, team)
      end
    end

    def toggl_dir
      permissions_dir.join 'toggl_teams'
    end

    def file_name(team_name)
      team_name = File.basename(team_name.gsub('\\', '/'))
      team_name.gsub!(/[^a-zA-Z0-9\.\-\+_]/, '_')
      team_name = "_#{team_name}" if team_name =~ /^\.+$/
      team_name
    end

    def recreate_toggl_dir
      FileUtils.rm_rf(toggl_dir)
      FileUtils.mkdir_p(toggl_dir)
    end
  end
end
