class ExpectedTeams

  def load!
    data.map do |name, members|
      Team.new(name, members)
    end
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
      YAML.load(File.read("#{permissions_repo_path}/teams.yml"))
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
