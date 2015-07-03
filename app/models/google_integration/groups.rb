module GoogleIntegration
  class Groups
    def self.all
      raw_data.map do |group_name, group_data|
        Group.new(
          group_name,
          group_data.members,
          group_data.aliases,
          group_data.domain_membership,
          group_data.privacy,
          group_data.archive,
        )
      end
    end

    def self.find_by(name:)
      all.find { |group| group.name == name }
    end

    private

    def self.raw_data
      Storage.data.google_groups
    end
  end
end
