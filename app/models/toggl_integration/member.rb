module TogglIntegration
  class Member
    attr_reader :emails, :toggl_id
    attr_accessor :repo_id

    def initialize(emails:, toggl_id: nil, repo_id: nil)
      @emails = emails
      @toggl_id = toggl_id.to_i unless toggl_id.nil?
      @repo_id = repo_id
    end

    def toggl_id?
      !toggl_id.nil?
    end

    def repo_id?
      !repo_id.nil?
    end

    def ==(other)
      return false unless self.class == other.class
      emails == other.emails && toggl_id == other.toggl_id && repo_id == other.repo_id
    end
  end
end
