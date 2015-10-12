class User
  attr_accessor :name, :full_name, :github, :emails, :rollbar, :external

  @errors = []
  class << self
    attr_reader :errors
  end

  def initialize(name:, full_name: '', github: '', emails: [''], rollbar: '', external: false)
    @name = name
    @full_name = full_name
    @github = github
    @rollbar = rollbar
    @emails = emails
    @external = external
  end

  def email
    emails.try(:first)
  end

  def self.company_name
    AppConfig.company
  end

  def to_yaml
    {
      name: full_name,
      github: github,
      external: external,
      emails: emails,
    }.stringify_keys.to_yaml
  end
end
