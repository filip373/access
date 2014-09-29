class ExpectedTeams

  def load!
    data
  end

  def all
    @all ||= load!
  end

  def data
    @data ||= begin
      teams = []
      
      Dir.glob("#{teams_repo_path}/*.yml") do |file_path|
        team_name = File.basename(file_path, '.yml')
        file_data = YAML.load(File.read(file_path))

        teams << Team.new(
          team_name,
          file_data['members'],
          file_data['repos']
        )
      end

      teams
    end
  end

  private

  def teams_repo_path
    "#{Rails.root}/tmp/permissions/teams"
  end
end
