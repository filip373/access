module GoogleIntegration
  class GroupPolicy
    @groups = Groups.all

    def self.edit?(group_email)
      whitelist.any? { |regexp| regexp.match group_email }
    end

    def self.whitelist
      AppConfig.google.groups_whitelist.map { |group| Regexp.new group }
    end
  end
end
