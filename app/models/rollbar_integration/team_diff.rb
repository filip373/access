module RollbarIntegration
  class TeamDiff
    include Celluloid

    attr_reader :dataguru_team, :rollbar_team, :repo, :rollbar_api
    attr_accessor :diff_hash

    def initialize(dataguru_team, rollbar_team, diff_hash, user_repo)
      @diff_hash = diff_hash
      @dataguru_team = dataguru_team
      @rollbar_team = rollbar_team || create_rollbar_team
      @rollbar_api = Api.new
      @errors = []
      @repo = user_repo
    end

    def diff(blk)
      members_diff
      projects_diff
    ensure
      blk.call(diff_hash, @errors)
      terminate
    end

    private

    def members_diff
      return operate_on_members(rollbar_team) if rollbar_team.id.present?
      operate_on_teams(rollbar_team) unless dataguru_members.empty?
    end

    def operate_on_members(rollbar_team)
      diff_hash[:add_members][rollbar_team] = add_members
      diff_hash[:remove_members][rollbar_team] = remove_members
    end

    def operate_on_teams(rollbar_team)
      diff_hash[:create_teams][rollbar_team][:add_members] = dataguru_members
    end

    def projects_diff
      return operate_projects_diff(rollbar_team) if rollbar_team.id.present?
      add_projects_to_team unless dataguru_projects.empty?
    end

    def operate_projects_diff(rollbar_team)
      diff_hash[:add_projects][rollbar_team] = add_projects
      diff_hash[:remove_projects][rollbar_team] = remove_projects
    end

    def add_projects_to_team
      diff_hash[:create_teams][rollbar_team][:add_projects] = dataguru_projects
    end

    def add_members
      dataguru_members.reject { |key, _e| rollbar_members.keys.include?(key) }
    end

    def remove_members
      members_to_remove = @rollbar_team.members.map(&:username) - dataguru_members.keys
      @rollbar_team.members.each_with_object({}) do |member, memo|
        memo[member.username] = member if members_to_remove.include?(member.username)
      end
    end

    def add_projects
      dataguru_projects.reject { |key, _e| rollbar_projects.keys.include?(key) }
    end

    def remove_projects
      projects_to_remove = @rollbar_team.projects.map(&:name) - @dataguru_team.projects
      @rollbar_team.projects.each_with_object({}) do |project, memo|
        memo[project.name] = project if projects_to_remove.include?(project.name)
      end
    end

    def create_rollbar_team
      diff_hash[:create_teams][dataguru_team] = {}
      dataguru_team
    end

    def dataguru_members
      return @dataguru_members if @dataguru_members.present?
      @dataguru_members = repo.find_many(dataguru_team.members)
      @errors.push(repo.errors) if repo.errors.present?
      @dataguru_members
    end

    def dataguru_projects
      return @dataguru_projects if @dataguru_projects.present?
      account_projects = Hash[
        rollbar_api.list_account_projects.map { |p| [p['name'], p['id']] }]
      @dataguru_projects = Hashie::Mash.new(
        Hash[
          dataguru_team.projects
          .map { |e| [e, { id: account_projects[e], name: e }] }
        ])
    end

    def rollbar_projects
      @rollbar_projects ||= if rollbar_team.respond_to?(:fake)
                              []
                            else
                              prepare_rollbar_projects_hash
                            end
    end

    def rollbar_members
      return @rollbar_members if @rollbar_members.present?
      if rollbar_team.respond_to?(:fake)
        @rollbar_members = []
      else
        @rollbar_members = prepare_rollbar_members_hash
      end
    end

    def prepare_rollbar_members_hash
      hash = Hash[
        list_all_team_members(rollbar_team.id)
        .map { |e| user_id_with_email(e) }
        ]
      hash.delete(nil)
      hash
    end

    def user_id_with_email(e)
      dataguru_user = repo.find_by_email(e.email)
    rescue => exception
      custom_error = "#{exception} rollbar_user: #{e}, team: #{rollbar_team}"
      @errors.push(custom_error)
      [nil, nil]
    else
      [dataguru_user.id, e]
    end

    def list_all_team_members(id)
      rollbar_api.list_all_team_members(id)
    end

    def prepare_rollbar_projects_hash
      hash = Hash[
                   rollbar_api
                   .list_team_projects(rollbar_team.id)
                   .map { |e| [e.name, e] }
                 ]
      hash.delete(nil)
      hash
    end
  end
end
