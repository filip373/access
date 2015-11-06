module TogglIntegration
  class MemberRepository
    attr_reader :all

    def initialize(all: [])
      @all = all
    end

    def find_by_emails(*emails)
      all.find { |member| (member.emails & emails).any? }
    end

    def self.build_from_toggl_api(toggl_api)
      members = toggl_api.list_all_members.map do |member|
        Member.new(
          emails: [member['email']],
          toggl_id: member['uid'],
          inactive: member['inactive']
        )
      end
      new(all: members)
    end
  end
end
