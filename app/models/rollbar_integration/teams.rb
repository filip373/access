module RollbarIntegration
  class Teams
    def self.all(raw_data)
      raw_data.map do |team|
        Team.new(
          team.name,
          team.members,
          team.projects,
        )
      end
    end
  end
end
