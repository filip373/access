module HockeyAppIntegration
  module MainHelper
    ROLES_HASH = {
      owners: 0,
      developers: 1,
      members: 2,
      testers: 3,
    }.freeze
    ID_ROLES_HASH = ROLES_HASH.invert.freeze

    def app_link(app_id)
      "https://rink.hockeyapp.net/manage/apps/#{app_id}"
    end

    def app_link_desc(app)
      "#{app.name} / #{app.optional_info[:platform]} / #{app.optional_info[:custom_release_type]}"
    end

    def self.role_to_id(role)
      ROLES_HASH[role]
    end

    def self.id_to_role(role)
      ID_ROLES_HASH[role]
    end
  end
end
