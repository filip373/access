require 'rails_helper'

describe TogglIntegration::Actions::Diff do
  describe '#call' do
    let(:local_doe) do
      TogglIntegration::Member.new(emails: ['john.doe@gmail.com'], id: 'john.doe')
    end
    let(:local_bond) do
      TogglIntegration::Member.new(emails: ['james.bond@gmail.com'], id: 'james.bond')
    end
    let(:local_luke) do
      TogglIntegration::Member.new(emails: ['lucky.luke@gmail.com'], id: 'lucky.luke')
    end
    let(:local_batman) do
      TogglIntegration::Member.new(emails: [], id: 'batman')
    end
    let(:local_without_team) do
      TogglIntegration::Member.new(emails: ['without_team@gmail.com'], id: 'without_team')
    end

    let(:local_team1) { TogglIntegration::Team.new(name: 'team1', members: [local_doe, local_bond], projects: ['team1'], tasks: []) }
    let(:local_team2) { TogglIntegration::Team.new(name: 'team2', members: [local_doe], projects: ['team2'], tasks: []) }
    let(:local_team3) { TogglIntegration::Team.new(name: 'team3', members: [local_doe, local_bond], projects: ['team3'], tasks: []) }
    let(:local_team4) { TogglIntegration::Team.new(name: 'team4', members: [local_doe], projects: ['team4'], tasks: []) }
    let(:local_team5) { TogglIntegration::Team.new(name: 'team5', members: [local_luke, local_batman], projects: ['team5'], tasks: []) }
    let(:local_teams) { [local_team1, local_team2, local_team3, local_team4, local_team5] }

    let(:toggl_doe) do
      TogglIntegration::Member.new(
        emails: ['john.doe@gmail.com'], toggl_id: '1', id: 'john.doe')
    end
    let(:toggl_wayne) do
      TogglIntegration::Member.new(
        emails: ['john.wayne@gmail.com'], toggl_id: '2', id: 'john.wayne')
    end
    let(:toggl_bond) do
      TogglIntegration::Member.new(
        emails: ['james.bond@gmail.com'], toggl_id: '3', id: 'james.bond')
    end
    let(:toggl_without_id) do
      TogglIntegration::Member.new(emails: ['without_id@gmail.com'], toggl_id: '4')
    end
    let(:toggl_inactive) do
      TogglIntegration::Member.new(emails: ['inactive@gmail.com'], toggl_id: '6', inactive: true)
    end
    let(:toggl_without_team) do
      TogglIntegration::Member.new(emails: ['without_team@gmail.com'], toggl_id: '5')
    end

    let(:toggl_team1) do
      TogglIntegration::Team.new(name: 'team1', members: [toggl_doe, toggl_without_id], projects: ['team1'], id: '1', tasks: [])
    end
    let(:toggl_team2) do
      TogglIntegration::Team.new(name: 'team2', members: [toggl_doe, toggl_bond, toggl_wayne], projects: ['team2'], id: '2', tasks: [])
    end
    let(:toggl_team6) do
      TogglIntegration::Team.new(
        name: 'team6',
        members: [toggl_doe, toggl_bond, toggl_wayne],
        projects: ['team6'],
        id: '6',
        tasks: [],
      )
    end
    let(:toggl_teams) { [toggl_team1, toggl_team2, toggl_team6] }

    let(:toggl_members_repo) do
      TogglIntegration::MemberRepository.new(
        all: [
          toggl_doe,
          toggl_bond,
          toggl_wayne,
          toggl_without_id,
          toggl_inactive,
          toggl_without_team])
    end
    let(:user_repository) do
      UserRepository.new([
        local_doe,
        local_bond,
        local_luke,
        local_batman,
        local_without_team
      ])
    end

    let(:task_1) { TogglIntegration::Task.new(name: 'Task_1', pid: 1) }
    let(:task_2) { TogglIntegration::Task.new(name: 'Task_2', pid: 2) }
    let(:task_3) { TogglIntegration::Task.new(name: 'Task_3', pid: 3) }
    let(:task_4) { TogglIntegration::Task.new(name: 'Task_4', pid: 4) }

    let(:toggl_tasks_repo) do
      TogglIntegration::TaskRepository.new(
        all: [
          task_1,
          task_2,
          task_3,
          task_4,
        ]
      )
    end

    let(:diff) do
      described_class.new(local_teams, toggl_teams, user_repository, toggl_members_repo, toggl_tasks_repo)
    end

    it 'returns hash with differences' do
      diff_result = diff.call
      expect(diff_result).to be_a(Hash)
    end

    it 'returns list of members to add' do
      diff_result = diff.call
      expect(diff_result[:add_members].size).to eq 1
      expect(diff_result[:add_members][toggl_team1].size).to eq 1
      expect(diff_result[:add_members][toggl_team1]).to eq [toggl_bond]
    end

    it 'returns list of members to deactivate' do
      diff_result = diff.call
      expect(diff_result[:deactivate_members]).to eq Set.new([toggl_without_id, toggl_wayne])
    end

    it 'returns list of members to remove' do
      diff_result = diff.call
      expect(diff_result[:remove_members][toggl_team1].size).to eq 1
      expect(diff_result[:remove_members][toggl_team1]).to eq [toggl_without_id]
    end

    it 'returns list of teams to create' do
      diff_result = diff.call
      expect(diff_result[:create_teams].size).to eq 3
      expect(diff_result[:create_teams][local_team3]).to eq([toggl_doe, toggl_bond])
      expect(diff_result[:create_teams][local_team4]).to eq [toggl_doe]
      expect(diff_result[:create_teams][local_team5]).to eq [local_luke]
    end

    it 'returns list of missing teams' do
      diff_result = diff.call
      expect(diff_result[:missing_teams]).to eq [toggl_team6]
    end

    it 'returns list of errors' do
      diff.call
      expect(diff.errors.count).to eq(2)
      expect(diff.errors[0]).to include(
        "User #{toggl_without_team.default_email} has no team assigned")
      expect(diff.errors[1]).to include('User batman has no email')
    end
  end
end
