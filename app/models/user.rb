class User
  attr_accessor :name, :full_name, :github, :emails, :rollbar, :external, :aliases

  @errors = []
  class << self
    attr_reader :errors
  end

  def initialize(name:, full_name: '', github: '', emails: [''], rollbar: '', external: false, aliases: [''])
    @name = name
    @full_name = full_name
    @github = github
    @rollbar = rollbar
    @emails = emails
    @external = external
    @aliases = aliases
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
      aliases: aliases,
    }.stringify_keys.to_yaml
  end
end
