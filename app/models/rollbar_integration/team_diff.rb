module RollbarIntegration
  class TeamDiff
    include Celluloid

    attr_reader :dataguru_team, :rollbar_team, :repo, :rollbar_api
    attr_accessor :diff_hash

    def initialize(dataguru_team, rollbar_team, diff_hash)
      @diff_hash = diff_hash
      @dataguru_team = dataguru_team
      @rollbar_team = rollbar_team || create_rollbar_team
      @rollbar_api = rollbar_api
      @errors = []
      @repo = UserRepository.new
      @rollbar_api = Api.new
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
      if rollbar_team.id.present?
        diff_hash[:add_members][rollbar_team] = add_members
        diff_hash[:remove_members][rollbar_team] = remove_members
      elsif !dataguru_members.empty?
        diff_hash[:create_teams][rollbar_team][:add_members] = dataguru_members
      end
    end

    def projects_diff
      if rollbar_team.id.present?
        diff_hash[:add_projects][rollbar_team] = add_projects
        diff_hash[:remove_projects][rollbar_team] = remove_projects
      elsif !dataguru_projects.empty?
        diff_hash[:create_teams][rollbar_team][:add_projects] = dataguru_projects
      end
    end

    def add_members
      dataguru_members.reject { |key, _e| rollbar_members.keys.include?(key) }
    end

    def remove_members
      rollbar_members.reject { |key, _e| dataguru_members.keys.include?(key) }
    end

    def add_projects
      dataguru_projects.reject { |key, _e| rollbar_projects.keys.include?(key) }
    end

    def remove_projects
      rollbar_projects.reject { |key, _e| dataguru_projects.keys.include?(key) }
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
                rollbar_api.list_all_team_members(rollbar_team.id)
                .map do |e|
                  begin
                    dataguru_user = repo.find_by_email(e.email)
                  rescue => exception
                    custom_error = "#{exception} rollbar_user: #{e}, team: #{rollbar_team}"
                    @errors.push(custom_error)
                    [nil, nil]
                  else
                    [dataguru_user.id, e]
                  end
                end
              ]
      hash.delete(nil)
      hash
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
