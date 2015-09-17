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
      hash.each do |key, user_hash|
        found = find(user_hash) if directory?(user_hash)
        return found if found
        return key => user_hash if user_hash['rollbar'] == username
      end
      false
    end

    def directory?(hash)
      !hash.key?('name')
    end
  end
end
