module GoogleIntegration
  class Group
    rattr_initialize :name, :members, :aliases, :domain_membership, :privacy, :archive do
      @privacy = GoogleIntegration::GroupPrivacy.from_string(@privacy)
    end

    delegate :open?, :closed?, :who_can_view_group, to: :privacy

    def self.from_google_api(group)
      privacy = GoogleIntegration::GroupPrivacy.from_google_api(group)
      new(
        username(group.email),
        group.members,
        group.aliases,
        !!group.members.find { |member| member['id'] == AppConfig.google.domain_member_id },
        privacy.to_s,
        group.settings.isArchived == 'true',
      )
    end

    def email
      "#{name}@#{AppConfig.google.main_domain}"
    end

    def build_users
      u = User.find_many(members)
      u.map do |name, data|
        if data.email.present?
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

    def archive?
      if archive.nil?
        GoogleIntegration::Defaults.group.archive
      else
        archive
      end
    end

    def to_yaml
      {
        domain_membership: domain_membership,
        members: Array(members).map { |user| Group.username(user.email || '') }.compact,
        aliases: Array(aliases).map { |email| Group.username(email) }.compact,
        privacy: privacy.to_s,
        archive: archive,
      }.stringify_keys.to_yaml
    end

    def errors
      nil
    end

    def self.username(email)
      email.split('@').first
    end
  end
end
