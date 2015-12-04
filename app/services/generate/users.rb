module Generate
  class Users
    pattr_initialize :google_api, :gh_api, :permissions_dir

    def call
      recreate_users_dir

      users.each do |user|
        File.open(file_path(user), 'w') do |f|
          f.write user.to_yaml
        end
      end
    end

    private

    def users
      @users = create_from_google_users
      match_or_create_from_github + @users
    end

    def create_from_google_users
      google_users.map do |user|
        User.new(
          name: username(user['primaryEmail']),
          full_name: user['name']['fullName'],
          emails: [user['primaryEmail']],
        )
      end
    end

    def match_or_create_from_github
      gh_users.map do |gh_user|
        gh_user = gh_api.get_user(gh_user['login'])
        user = match_google_user(gh_user)
        add_info_about_user_from_gh(user, gh_user)
      end.compact
    end

    def add_info_about_user_from_gh(user, gh_user)
      if user.present?
        user.github = gh_user['login']
        user.external = false
        nil
      else
        new_user_from_github(gh_user)
      end
    end

    def new_user_from_github(gh_user)
      User.new(
        name: slugify(gh_user['name'] || gh_user['login']),
        full_name: gh_user['name'] || gh_user['login'].capitalize,
        github: gh_user['login'],
        external: true,
      )
    end

    def google_users
      google_api.list_users
    end

    def gh_users
      gh_api.list_org_members(AppConfig.company)
    end

    def match_google_user(gh_user)
      return unless gh_user
      @users.find do |u|
        u.emails.include?(gh_user['email']) || u.name == slugify(gh_user['name'])
      end
    end

    def slugify(name)
      return unless name.present?
      I18n.transliterate(name).tr(' ', '.').downcase
    end

    def file_path(user)
      if user.external
        "#{external_users_dir}/#{user.name}.yml"
      else
        "#{company_users_dir}/#{user.name}.yml"
      end
    end

    def username(email)
      email.split('@').first
    end

    def company_users_dir
      users_dir.join "#{AppConfig.company}"
    end

    def external_users_dir
      users_dir.join 'external'
    end

    def users_dir
      permissions_dir.join 'users'
    end

    def recreate_users_dir
      FileUtils.rm_rf(users_dir)
      FileUtils.mkdir_p(users_dir)
      FileUtils.mkdir_p(external_users_dir)
      FileUtils.mkdir_p(company_users_dir)
    end
  end
end
