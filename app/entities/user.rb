class User

  def self.find(name)
    if name.include?("/") #namespace lookup i.e netguru/marcin.stecki
      namespace_lookup(name)
    else
      user_data = users_data[name]
      if user_data.nil? && users_data[AppConfig.company].present?
        users_data[AppConfig.company][name]
      end
    end
  end

  def self.namespace_lookup(name)
    parts = name.split("/")
    nick = parts.last
    nesting = parts[0..-2]
    user_directory = users_data
    nesting.each{|part| user_directory = user_directory[part] }
    user_directory[name]
  end

  def self.users_data
    Storage.data.users
  end

end
