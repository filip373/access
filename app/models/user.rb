class UserError < StandardError; end

class User
  attr_accessor :name, :full_name, :github, :emails, :html_url, :rollbar

  @errors = []
  class << self
    attr_reader :errors
  end

  def initialize(name:, full_name: '', github: '', emails: [''], html_url: '',
                 rollbar: '')
    @name = name
    @full_name = full_name
    @github = github
    @rollbar = rollbar
    @emails = emails
    @html_url = html_url
  end

  def self.find(name)
    user =
      if name.include?('/')
        nick = name.split('/').last
        users_data.find { |u| u.id == nick }
      else
        users_data.find { |u| u.id == name }
      end
    user || fail(UserError, "Unknown user #{name}. It's not in directory users or it is in wrong directory")
  end

  def self.find_by_email(email)
    user = users_data.find do |u|
      u.emails.include?(email)
    end
    user || fail(UserError, "User with email: #{email} does not exist.")
  end

  def self.list_company_users
    users_data.reject(&:external)
  end

  def self.find_many(names)
    users = names.map do |n|
      begin
        user = User.find(n)
      rescue StandardError => e
        add_error(e)
      else
        [user.id, user]
      end
    end
    Hash[users.compact]
  end

  def self.add_error(error)
    @errors.push(error.to_s)
    Rollbar.error(error)
    nil
  end

  def self.company_name
    AppConfig.company
  end

  def self.users_data
    DataGuru::Client.new.users
  end

  def self.shift_errors
    tmp_errors = @errors.clone
    @errors = []
    tmp_errors
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
