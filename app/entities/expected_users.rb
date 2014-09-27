class ExpectedUsers

  def load!
    data
  end

  def all
    @all ||= load!
  end

  def data
    @data ||= begin
      users = {}
      
      Dir.glob("#{users_repo_path}/*.yml") do |file_path|
        user_name = File.basename(file_path, '.yml')
        file_data = YAML.load(File.read(file_path))

        users[user_name] = User.new(user_name, file_data['github'])
      end

      users
    end
  end

  private

  def users_repo_path
    "#{Rails.root}/tmp/permissions/users"
  end
end
