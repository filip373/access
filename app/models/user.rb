class User

  def self.find(name)
    if name.include?("/") #namespace lookup i.e netguru/marcin.stecki
      namespace_lookup(name)
    else
      user_data = users_data[name]
      if user_data.nil? && users_data[company_name].present?
        users_data[company_name][name]
      end
    end
  end

  def self.namespace_lookup(name)
    parts = name.split("/")
    nick = parts.last
    parts = parts[0..-2]
    user_directory = users_data
    parts.each{|part| user_directory = user_directory[part] }
    user_directory[nick]
  end

  def self.company_name
    AppConfig.company
  end

  def self.users_data
    Storage.data.users
  end

end
