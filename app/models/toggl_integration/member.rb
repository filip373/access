module TogglIntegration
  class Member
    attr_reader :emails, :toggl_id, :inactive
    attr_accessor :id

    def initialize(emails:, toggl_id: nil, id: nil, inactive: false)
      @emails = emails
      @toggl_id = toggl_id.to_i unless toggl_id.nil?
      @id = id
      @inactive = inactive
    end

    def toggl_id?
      !toggl_id.nil?
    end

    def id?
      !id.nil?
    end

    def inactive?
      inactive
    end

    def active?
      !inactive
    end

    def ==(other)
      return false unless self.class == other.class
      emails == other.emails && toggl_id == other.toggl_id && id == other.id
    end

    def eql?(other)
      self == other
    end

    def hash
      [@emails, @toggl_id, @id].hash
    end

    def default_email
      @emails.first
    end
  end
end
