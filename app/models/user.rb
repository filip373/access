class User
  def self.find(name)
    if name.include?('/')
      user = namespace_lookup(name)
    else
      user = users_data[name] || users_data.try(:[], company_name).try(:[], name)
    end
    user || raise("Unknown user #{name}. It's not in directory users or it is in wrong directory")
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
      user = User.find(n)
      raise "Unknown user #{n}" if user.nil?
      [n, user]
    end
    Hash[users]
  end

  def self.company_name
    AppConfig.company
  end

  def self.users_data
    Storage.data.users
  end
end
