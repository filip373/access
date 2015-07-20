module GoogleIntegration
  class GroupPolicy
    def self.edit?(group_email, is_admin = false)
      return true if is_admin
      whitelist.any? { |regexp| regexp.match group_email }
    end

    def self.whitelist
      AppConfig.google.groups_whitelist.map { |group| Regexp.new group }
    end
  end
end
