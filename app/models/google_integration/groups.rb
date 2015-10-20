module GoogleIntegration
  class Groups
    def self.all(raw_data)
      raw_data.map do |group|
        Group.new(
          group.id,
          group.members,
          group.aliases,
          group.domain_membership,
          GroupPrivacy.from_bool(group.private).to_s,
          group.archive,
        )
      end
    end

    def self.find_by(name:)
      all.find { |group| group.name == name }
    end
  end
end
