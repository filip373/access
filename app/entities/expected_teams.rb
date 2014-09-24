class ExpectedTeams

  def load!
    data
  end

  def all
    @all ||= load!
  end

  def data
    @data ||= begin
      if File.exists? permissions_repo_path
        update
      else
        clone
      end
      
      teams = []
      Dir.glob("#{permissions_repo_path}/teams/*.yml") do |file_path|
        team_name = File.basename(file_path, '.yml')
        file_data = YAML.load(File.read(file_path))

        teams << Team.new(team_name, file_data['members'], file_data['repos'])
      end

      teams
    end
  end

  def clone
    FileUtils.mkdir_p(permissions_repo_path)
    Git.clone(AppConfig.permissions_repo.git, 'permissions', path: "#{Rails.root}/tmp")
  end

  def update
    Git.open(permissions_repo_path).pull
  end

  def permissions_repo_path
    "#{Rails.root}/tmp/permissions"
  end

end
