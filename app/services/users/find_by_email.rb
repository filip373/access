module Users
  class FindByEmail
    attr_accessor :users_data, :email

    def initialize(users_data: User.users_data, email:)
      self.users_data = users_data
      self.email = email
    end

    def call
      find(users_data)
    end

    private

    def find(hash)
      hash.each do |key, user_hash|
        found = find(user_hash) if directory?(user_hash)
        return found if found
        return instantiated_user(key, user_hash) if email_matched?(user_hash)
      end
      false
    end

    def email_matched?(user_hash)
      user_hash['email'] == email
    end

    def directory?(hash)
      !hash.key?('name')
    end

    def instantiated_user(key, user_hash)
      User.new(full_name: user_hash['name'], name: key,
               github: user_hash['github'],
               email: user_hash['email'])
    end
  end
end
