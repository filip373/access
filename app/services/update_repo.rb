class UpdateRepo
  def self.now!
    if File.exist? permissions_checkout_dir
      update
    else
      clone
    end
  end

  def self.clone
    FileUtils.mkdir_p(permissions_checkout_dir)
    Git.clone(repo_address, 'permissions', path: "#{Rails.root}/tmp")
  end

  def self.update
    Git.open(permissions_checkout_dir).pull
  end

  def self.permissions_checkout_dir
    "#{Rails.root}/#{AppConfig.permissions_repo.checkout_dir}"
  end

  def self.repo_address
    AppConfig.permissions_repo.git
  end
end
