class UserError < StandardError; end

class User
  attr_accessor :name, :full_name, :github, :emails, :rollbar

  @errors = []
  class << self
    attr_reader :errors
  end

  def initialize(name:, full_name: '', github: '', emails: [''], rollbar: '')
    @name = name
    @full_name = full_name
    @github = github
    @rollbar = rollbar
    @emails = emails
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
      emails: emails,
    }.stringify_keys.to_yaml
  end

  def external?
    emails.map do |email|
      email.split('@').last != AppConfig.google.main_domain
    end.first
  end
end
