require 'rails_helper'

describe TogglIntegration::Actions::Diff do
  describe '#call' do
    let(:local_doe) do
      TogglIntegration::Member.new(emails: ['john.doe@gmail.com'], repo_id: 'john.doe')
    end
    let(:local_bond) do
      TogglIntegration::Member.new(emails: ['james.bond@gmail.com'], repo_id: 'james.bond')
    end
    let(:local_luke) do
      TogglIntegration::Member.new(emails: ['lucky.luke@gmail.com'], repo_id: 'lucky.luke')
    end
    let(:local_batman) do
      TogglIntegration::Member.new(emails: [], repo_id: 'batman')
    end

    let(:local_team1) { TogglIntegration::Team.new('team1', [local_doe, local_bond], ['team1']) }
    let(:local_team2) { TogglIntegration::Team.new('team2', [local_doe], ['team2']) }
    let(:local_team3) { TogglIntegration::Team.new('team3', [local_doe, local_bond], ['team3']) }
    let(:local_team4) { TogglIntegration::Team.new('team4', [local_doe], ['team4']) }
    let(:local_team5) { TogglIntegration::Team.new('team5', [local_luke, local_batman], ['team5']) }
    let(:local_teams) { [local_team1, local_team2, local_team3, local_team4, local_team5] }

    let(:toggl_doe) do
      TogglIntegration::Member.new(emails: ['john.doe@gmail.com'], toggl_id: '1')
    end
    let(:toggl_wayne) do
      TogglIntegration::Member.new(emails: ['john.wayne@gmail.com'], toggl_id: '2')
    end
    let(:toggl_bond) do
      TogglIntegration::Member.new(emails: ['james.bond@gmail.com'], toggl_id: '3')
    end

    let(:toggl_team1) do
      TogglIntegration::Team.new('team1', [toggl_doe], ['team1'], '1')
    end
    let(:toggl_team2) do
      TogglIntegration::Team.new('team2', [toggl_doe, toggl_bond, toggl_wayne], ['team2'], '2')
    end
    let(:toggl_team6) do
      TogglIntegration::Team.new(
        'team6',
        [toggl_doe, toggl_bond, toggl_wayne],
        ['team6'],
        '6',
      )
    end
    let(:toggl_teams) { [toggl_team1, toggl_team2, toggl_team6] }

    let(:toggl_members_repo) do
      TogglIntegration::MemberRepository.new(all: [toggl_doe, toggl_bond, toggl_wayne])
    end
    let(:diff) do
      described_class.new(local_teams, toggl_teams, toggl_members_repo)
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

    it 'returns list of members to remove' do
      diff_result = diff.call
      expect(diff_result[:remove_members].size).to eq 1
      expect(diff_result[:remove_members][toggl_team2].size).to eq 2
      expect(diff_result[:remove_members][toggl_team2][0].emails).to eq ['james.bond@gmail.com']
      expect(diff_result[:remove_members][toggl_team2][1].emails).to eq ['john.wayne@gmail.com']
    end

    it 'returns list of teams to create' do
      diff_result = diff.call
      expect(diff_result[:create_teams].size).to eq 3
      expect(diff_result[:create_teams][local_team3]).to eq([toggl_doe, toggl_bond])
      expect(diff_result[:create_teams][local_team4]).to eq [toggl_doe]
      expect(diff_result[:create_teams][local_team5]).to eq []
    end

    it 'returns list of missing teams' do
      diff_result = diff.call
      expect(diff_result[:missing_teams]).to eq [toggl_team6]
    end

    it 'returns list of errors' do
      diff.call
      expect(diff.errors.count).to eq(2)
      expect(diff.errors[0]).to include('User lucky.luke has no account')
      expect(diff.errors[1]).to include('User batman has no email')
    end
  end
end
