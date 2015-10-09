module TogglIntegration
  class MemberRepository
    attr_reader :all

    def initialize(all: [])
      @all = all
    end

    def find_by_toggl_id(toggl_id)
      return if toggl_id.nil?
      toggl_id = toggl_id.to_i
      all.find { |member| member.toggl_id == toggl_id }
    end

    def find_by_emails(*emails)
      all.find { |member| (member.emails & emails).any? }
    end

    def find_by_repo_id(repo_id)
      return if repo_id.nil?
      all.find { |member| member.repo_id == repo_id }
    end

    def self.build_from_toggl_api(toggl_api)
      members = toggl_api.list_all_members.map do |member|
        Member.new(emails: [member['email']], toggl_id: member['uid'])
      end
      new(all: members)
    end

    def self.build_from_data_guru(dg_client)
      members = dg_client.users.map do |user|
        Member.new(emails: user.emails, repo_id: user.id)
      end
      new(all: members)
    end
  end
end
