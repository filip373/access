module TogglIntegration
  class TeamRepository
    attr_accessor :all

    def initialize(all: [])
      self.all = all
    end

    def self.build_from_data_guru(dg_client, user_repository, toggl_members_repository)
      teams = dg_client.toggl_teams.map do |team|
        members = prepare_members(team, user_repository, toggl_members_repository)
        tasks = team.tasks.try(:map) { |repo_task| Task.new(name: repo_task, pid: team.id) }
        Team.new(name: team.name,
                 members: members || [],
                 projects: team.projects,
                 tasks: tasks || [])
      end
      new(all: teams)
    end

    def self.prepare_members(team, user_repo, toggl_members_repository)
      team.members.try(:map) do |repo_member|
        member_data = prepare_member_data(user_repo, repo_member)
        emails = member_data ? member_data.emails : []
        toggl_member = toggl_members_repository.find_by_emails(*emails) if emails.any?
        toggl_id = toggl_member.toggl_id if toggl_member
        Member.new(emails: emails, id: repo_member, toggl_id: toggl_id)
      end
    end

    def self.prepare_member_data(user_repo, repo_member)
      user_repo.find(repo_member)
    rescue
      nil
    end

    def self.build_from_toggl_api(toggl_api, user_repository)
      teams = toggl_api.list_teams.map do |team|
        Team.new(name: team['name'],
                 members: team_members(toggl_api, team, user_repository),
                 projects: [team['name']],
                 tasks: team_tasks(toggl_api, team),
                 id: team['id'],
                )
      end
      new(all: teams)
    end

    def self.team_tasks(api, team)
      api.list_all_tasks(team['id']).map do |task|
        Task.new(name: task['name'], pid: team['id'])
      end
    end

    def self.team_members(api, team, user_repository)
      api.list_team_members(team['id']).map do |api_member|
        member = Member.new(emails: [api_member['email']], toggl_id: api_member['uid'])
        member.id =
          begin
            user_repository.find_by_email(api_member['email']).id
          rescue
            nil
          end
        member
      end
    end

    def self.team_projects(team)
      [team['name']]
    end
  end
end
