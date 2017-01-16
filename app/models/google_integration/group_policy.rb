module GoogleIntegration
  class GroupPolicy
    def self.edit?(group_email, is_admin = false)
      return true if is_admin
      !blacklist.include?(group_email.downcase)
    end

    def self.blacklist
      @_blacklist ||= AppConfig.google.groups_blacklist.map(&:downcase)
    end
  end
end
