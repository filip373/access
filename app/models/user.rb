class UserError < StandardError; end

class User
  attr_accessor :name, :full_name, :github, :email, :html_url, :rollbar

  @errors = []
  class << self
    attr_reader :errors
  end

  def initialize(name:, full_name: '', github: '', email: '', html_url: '',
                 rollbar: '')
    @name = name
    @full_name = full_name
    @github = github
    @rollbar = rollbar
    @email = email
    @html_url = html_url
  end

  def self.find(name)
    user =
      if name.include?('/')
        namespace_lookup(name)
      else
        users_data[name] ||
        users_data.fetch(company_name, {}).fetch(name, nil) ||
        users_data.fetch('external', {}).fetch(name, nil)
      end
    user || fail("Unknown user #{name}. It's not in directory users or it is in wrong directory")
  end

  def self.find_by_rollbar(username)
<<<<<<< HEAD
    user = Users::FindByRollbar.new(username: username).call
    user || fail(UserError, "User with rollbar login: #{username} does not exist.")
=======
    users_data.find { |u| u.rollbar == nickname } ||
      fail UserError, "User with rollbar login: #{username} does not exist."
>>>>>>> remove FindByRollbar service
  end

  def self.find_by_email(email)
    user = Users::FindByEmail.new(email: email).call
    user || fail(UserError, "User with email: #{email} does not exist in directory users.")
  end

  def self.list_company_users
    users_data.fetch(company_name, {})
  end

  def self.namespace_lookup(name)
    parts = name.split('/')
    nick = parts.last
    parts = parts[0..-2]
    user_directory = users_data
    parts.each { |part| user_directory = user_directory[part] }
    user_directory[nick]
  end

  def self.find_many(names)
    users = names.map do |n|
      begin
        user = User.find(n)
      rescue StandardError => e
        add_error(e)
      else
        [n, user]
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
    Storage.data.users
  end

  def self.find_user_by_github(login)
    user = Storage.data.users.map { |_k, users| users.values }.flatten.find do |entry|
      entry['github'].to_s.downcase == login.downcase
    end
    User.new(github: login,
             name: user.try(:name),
             email: user.try(:email))
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
      email: email,
    }.stringify_keys.to_yaml
  end

  def external?
    email.split('@').last != AppConfig.google.main_domain
  end
end
