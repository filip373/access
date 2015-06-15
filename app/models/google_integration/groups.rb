module GoogleIntegration
  class Groups
    def self.all
      raw_data.map do |group_name, group_data|
        Group.new(
          group_name,
          group_data.members,
          group_data.aliases,
          group_data.privacy,
          group_data.archive,
          group_data.domain_membership
        )
      end
    end

    private

    def self.raw_data
      Storage.data.google_groups
    end
  end

  class Group
    rattr_initialize :name, :members, :aliases, :privacy, :archive, :domain_membership

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
      if closed? then false else true end
    end

    def who_can_view_group
      if closed?
        'ALL_MEMBERS_CAN_VIEW'
      else
        'ALL_IN_DOMAIN_CAN_VIEW'
      end
    end

    def archive?
      return archive if archive.present?
      if closed? then false else true end
    end

    def closed?
      privacy == 'closed'
    end

    def open?
      return true if privacy.nil?
      privacy == 'open'
    end
  end
end
