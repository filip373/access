module RollbarIntegration
  class TeamDiff
    include Celluloid

    attr_reader :server_team, :yaml_team, :rollbar_api
    attr_accessor :diff_hash

    def initialize(yaml_team, server_team, rollbar_api, diff_hash)
      @diff_hash = diff_hash
      @yaml_team = yaml_team
      @server_team = server_team || create_server_team
      @rollbar_api = rollbar_api
      @errors = []
    end

    def diff(blk)
      members_diff
      projects_diff
    rescue StandardError => e
      Rollbar.error(e)
    ensure
      blk.call(diff_hash, @errors)
      terminate
    end

    private

      if server_team.respond_to?(:id)
        server_members = server_team.respond_to?(:fake) ? [] : list_team_members(server_team['id'])
        @diff_hash[:add_members][server_team] = yaml_members - server_members
        @diff_hash[:remove_members][server_team] = server_members - yaml_members
    def members_diff
      elsif !yaml_members.empty?
        @diff_hash[:create_teams][server_team][:add_members] = yaml_members
      end
    end

      if server_team.respond_to?(:id)
        server_projects = server_team.respond_to?(:fake) ? [] : list_team_projects(server_team['id'])

        @diff_hash[:add_projects][server_team] = yaml_projects - server_projects
        @diff_hash[:remove_projects][server_team] = server_projects - yaml_projects
    def projects_diff
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
