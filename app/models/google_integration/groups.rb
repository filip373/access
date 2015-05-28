module GoogleIntegration
  class Groups
    def self.all
      raw_data.map do |group_name, group_data|
        Group.new(
          group_name,
          group_data.members,
          group_data.aliases,
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
    attr_reader :name, :members, :aliases, :domain_membership

    def initialize(name, members, aliases, domain_membership)
      @name = name
      @members = members
      @aliases = aliases
      @domain_membership = domain_membership
    end

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
  end
end
