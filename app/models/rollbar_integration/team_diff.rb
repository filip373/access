module RollbarIntegration
  class TeamDiff
    include Celluloid

    def initialize(yaml_team, server_team, rollbar_api, diff_hash)
      @diff_hash = diff_hash
      @yaml_team = yaml_team
      @server_team = server_team || create_server_team
      @rollbar_api = rollbar_api
      @errors = []
    end

    def diff(blk)
      yaml_members = map_users_to_emails
      members_diff(@server_team, yaml_members)
      projects_diff(@server_team, @yaml_team.projects)
    rescue StandardError => e
      Rollbar.error(e)
    ensure
      blk.call(@diff_hash, @errors)
      terminate
    end

    private

    def members_diff(server_team, yaml_members)
      if server_team.respond_to?(:id)
        server_members = server_team.respond_to?(:fake) ? [] : list_team_members(server_team['id'])
        @diff_hash[:add_members][server_team] = yaml_members - server_members
        @diff_hash[:remove_members][server_team] = server_members - yaml_members
      elsif !yaml_members.empty?
        @diff_hash[:create_teams][server_team][:add_members] = yaml_members
      end
    end

    def projects_diff(server_team, yaml_projects)
      if server_team.respond_to?(:id)
        server_projects = server_team.respond_to?(:fake) ? [] : list_team_projects(server_team['id'])

        @diff_hash[:add_projects][server_team] = yaml_projects - server_projects
        @diff_hash[:remove_projects][server_team] = server_projects - yaml_projects
      elsif !yaml_projects.empty?
        @diff_hash[:create_teams][server_team][:add_projects] = yaml_projects
      end
    end

    def list_team_members(team_id)
      @rollbar_api.list_team_members(team_id).map { |e| e['email'] }
    end

    def list_team_projects(team_id)
      @rollbar_api.list_team_projects(team_id).map { |e| e['name'] }
    end

    def create_server_team
      @diff_hash[:create_teams][@yaml_team] = {}
      @yaml_team
    end

    def map_users_to_emails
      users = User.find_many(@yaml_team.members)
      @errors.push(*User.shift_errors) if User.errors.present?
      users.values.map(&:email)
    end
  end
end
