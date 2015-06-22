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
        GoogleIntegration::Group.new(
          username(group.email),
          group.members,
          group.aliases,
          !!group.members.find { |member| member['id'] == AppConfig.google.domain_member_id },
          privacy(group),
          group.settings.isArchived == 'true',
        )
      end
    end

    def username(email)
      email.split('@').first
    end

    def privacy(group)
      normalized_privacy = Hashie::Mash.new(
        show_in_group_directory: group.settings.showInGroupDirectory,
        who_can_view_group: group.settings.whoCanViewGroup,
      )

      GoogleIntegration::GroupPrivacy.new(normalized_privacy).to_s
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
