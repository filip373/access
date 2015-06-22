module GoogleIntegration
  class Group
    rattr_initialize :name, :members, :aliases, :domain_membership, :privacy, :archive

    def email
      "#{name}@#{AppConfig.google.main_domain}"
    end

    def build_users
      u = User.find_many(members)
      u.map do |name, data|
        if data.email?
          data.email
        else
          "#{name}@#{AppConfig.google.main_domain}"
        end
      end
    end

    def users
      return [] unless members.present?
      @users ||= build_users
    end

    def show_in_group_directory?
      open?
    end

    def who_can_view_group
      if closed?
        'ALL_MEMBERS_CAN_VIEW'
      else
        'ALL_IN_DOMAIN_CAN_VIEW'
      end
    end

    def archive?
      return archive unless archive.nil?
      false
    end

    def closed?
      privacy == 'closed'
    end

    def open?
      privacy.nil? || privacy == 'open'
    end

    def to_yaml
      {
        domain_membership: domain_membership,
        members: Array(members).map { |user| username(user.email || '') }.compact,
        aliases: Array(aliases).map { |email| username(email) }.compact,
        privacy: privacy,
        archive: archive,
      }.stringify_keys.to_yaml
    end

    def username(email)
      email.split('@').first
    end

    def errors
      nil
    end
  end
end
