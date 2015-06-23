module Generate
  class GooglePermissions
    pattr_initialize :google_groups, :permissions_dir

    def call
      recreate_google_dir

      groups.each do |group|
        File.open(google_dir.join("#{group.name}.yml"), 'w') do |f|
          f.write group.to_yaml
        end
      end
    end

    private

    def groups
      @groups ||= google_groups.map do |group|
        GoogleIntegration::Group.from_google_api(group)
      end
    end

    def google_dir
      permissions_dir.join 'google_groups'
    end

    def recreate_google_dir
      FileUtils.rm_rf(google_dir)
      FileUtils.mkdir_p(google_dir)
    end
  end
end
