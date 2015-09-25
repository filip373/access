module Users
  class FindByRollbar
    attr_accessor :users_data, :username

    def initialize(users_data: User.users_data, username:)
      self.users_data = users_data
      self.username = username
    end

    def call
      find(users_data)
    end

    private

    def find(hash)
      hash.each do |name, user_hash|
        found = find(user_hash) if directory?(user_hash)
        return found if found
        return instantiated_user(name, user_hash) if username_matched?(user_hash)
      end
      false
    end

    def username_matched?(user_hash)
      user_hash['rollbar'] == username
    end

    def directory?(hash)
      !hash.key?('name')
    end

    def instantiated_user(name, user_hash)
      User.new(full_name: user_hash['name'], name: name,
               github: user_hash['github'], rollbar: user_hash['rollbar'],
               email: user_hash['email'])
    end
  end
end
