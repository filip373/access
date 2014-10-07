module Actions
  class SyncPermissions

    def now!
      if File.exists? permissions_repo_path
        update
      else
        clone
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
end
