module TogglIntegration
  class Member
    attr_reader :emails, :toggl_id, :repo_id

    def initialize(emails:, toggl_id: nil, repo_id: nil)
      @emails = emails
      @toggl_id = toggl_id.to_i unless toggl_id.nil?
      @repo_id = repo_id
    end
  end
end
