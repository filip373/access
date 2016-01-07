class UserRepository
  attr_accessor :users_data, :errors

  def initialize(users_data = nil)
    @users_data = users_data || DataGuru::Client.new.members
    @errors = []
  end

  def find(name)
    user =
      if name.include?('/')
        nick = name.split('/').last
        users_data.find { |u| u.id == nick }
      else
        users_data.find { |u| u.id == name }
      end
    user || fail(UserError,
                 "Unknown user #{name}. It's not in members/ directory or it is in wrong directory")
  end

  def find_by_email(email)
    user = users_data.find do |u|
      u.emails.include?(email)
    end
    user || fail(UserError, "User with email: #{email} does not exist.")
  end

  def find_many(names)
    users = find_users_by_name(names)
    prepare_array_with_names(users)
  end

  def find_users_by_name(names)
    names.map do |n|
      begin
        user = find(n)
      rescue StandardError => e
        errors.push(e.to_s)
        Rollbar.error(e)
      else
        [user.id, user]
      end
    end
  end

  def prepare_array_with_names(users)
    users.compact.each_with_object({}) do |user, memo|
      next unless user.is_a?(Array)
      memo[user.first] = user.last
    end
  end

  def list_company_users
    users_data.reject(&:external)
  end
end
