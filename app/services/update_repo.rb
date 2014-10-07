class UpdateRepo

  def now!
    if File.exists? permissions_checkout_dir
      update
    else
      clone
    end
  end

  def clone
    FileUtils.mkdir_p(permissions_checkout_dir)
    Git.clone(AppConfig.permissions_repo.git, 'permissions', path: "#{Rails.root}/tmp")
  end

  def update
    Git.open(permissions_checkout_dir).pull
  end

  def permissions_checkout_dir
    "#{Rails.root}/#{AppConfig.permissions_repo.checkout_dir}"
  end

end
