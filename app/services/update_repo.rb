class UpdateRepo
  def now!
    Rollbar.info('UpdateRepo.now!', permissions_checkout_dir: permissions_checkout_dir)
    if File.exist? permissions_checkout_dir
      update
    else
      clone
    end
  end

  def clone
    FileUtils.mkdir_p(permissions_checkout_dir)
    Git.clone(repo_address, 'permissions', path: "#{Rails.root}/tmp")
  end

  def update
    Git.open(permissions_checkout_dir).pull
  end

  def permissions_checkout_dir
    "#{Rails.root}/#{AppConfig.permissions_repo.checkout_dir}"
  end

  def repo_address
    AppConfig.permissions_repo.git
  end
end
