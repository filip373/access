module RollbarIntegration
  class TeamDiff
    include Celluloid

    attr_reader :server_team, :yaml_team, :rollbar_api, :repo
    attr_accessor :diff_hash

    def initialize(yaml_team, server_team, rollbar_api, diff_hash)
      @diff_hash = diff_hash
      @yaml_team = yaml_team
      @server_team = server_team || create_server_team
      @rollbar_api = rollbar_api
      @errors = []
      @repo = UserRepository.new
    end

    def diff(blk)
      members_diff
      projects_diff
    rescue StandardError => e
    ensure
      blk.call(diff_hash, @errors)
      terminate
    end

    private

    def members_diff
      if server_team.id.present?
        diff_hash[:add_members][server_team] = add_members
        diff_hash[:remove_members][server_team] = remove_members
      elsif !yaml_members.empty?
        diff_hash[:create_teams][server_team][:add_members] = yaml_members
      end
    end

    def projects_diff
      if server_team.id.present?
        diff_hash[:add_projects][server_team] = add_projects
        diff_hash[:remove_projects][server_team] = remove_projects
      elsif !yaml_projects.empty?
        diff_hash[:create_teams][server_team][:add_projects] = yaml_projects
      end
    end

    def add_members
      yaml_members.reject { |key, _e| server_members.keys.include?(key) }
    end

    def remove_members
      server_members.reject { |key, _e| yaml_members.keys.include?(key) }
    end

    def add_projects
      yaml_projects.reject { |key, _e| server_projects.keys.include?(key) }
    end

    def remove_projects
      server_projects.reject { |key, _e| yaml_projects.keys.include?(key) }
    end

    def create_server_team
      diff_hash[:create_teams][yaml_team] = {}
      yaml_team
    end

    def yaml_members
      return @yaml_members if @yaml_members.present?
      @yaml_members = repo.find_many(yaml_team.members)
      @errors.push(repo.errors) if repo.errors.present?
      @yaml_members
    end

    def yaml_projects
      return @yaml_projects if @yaml_projects.present?
      account_projects = Hash[
        rollbar_api.list_account_projects.map { |p| [p['name'], p['id']] }]
      @yaml_projects = Hashie::Mash.new(
        Hash[
          yaml_team.projects
          .map { |e| [e, { id: account_projects[e], name: e }] }
        ])
    end

    def server_projects
      @server_projects ||= if server_team.respond_to?(:fake)
                             []
                           else
                             prepare_server_projects_hash
                           end
    end

    def server_members
      return @server_members if @server_members.present?
      if server_team.respond_to?(:fake)
        @server_members = []
      else
        @server_members = prepare_server_members_hash
      end
    end

    def prepare_server_members_hash
      hash = Hash[
                rollbar_api.list_all_team_members(server_team['id'])
                .map do |e|
                  begin
                    yaml_user = repo.find_by_email(e.email)
                  rescue => exception
                    custom_error = "#{exception} rollbar_user: #{e}, team: #{server_team}"
                    @errors.push(custom_error)
                    [nil, nil]
                  else
                    [yaml_user.id, e]
                  end
                end
              ]
      hash.delete(nil)
      hash
    end

    def prepare_server_projects_hash
      hash = Hash[
                   rollbar_api
                   .list_team_projects(server_team['id'])
                   .map { |e| [e.name, e] }
                 ]
      hash.delete(nil)
      hash
    end
  end
end
