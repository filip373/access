require 'rails_helper'

describe TogglIntegration::Actions::Diff do
  describe '#call' do
    let(:local_team1) { TogglIntegration::Team.new('team1', ['john.doe', 'james.bond'], ['team1']) }
    let(:local_team2) { TogglIntegration::Team.new('team2', ['john.doe', 'james.bond'], ['team2']) }
    let(:local_team3) { TogglIntegration::Team.new('team3', ['john.doe', 'james.bond'], ['team3']) }
    let(:local_team4) { TogglIntegration::Team.new('team4', ['john.doe'], ['team4']) }
    let(:local_team5) { TogglIntegration::Team.new('team5', ['lucky.luke', 'winnetou'], ['team5']) }
    let(:local_teams) { [local_team1, local_team2, local_team3, local_team4, local_team5] }

    let(:server_team1) do
      TogglIntegration::Team.new('team1', ['john.doe@gmail.com'], ['team1'], '1')
    end
    let(:server_team2) do
      TogglIntegration::Team.new(
        'team2',
        ['john.doe@gmail.com', 'james.bond@gmail.com', 'john.wayne@gmail.com'],
        ['team2'],
        '2')
    end
    let(:server_team6) do
      TogglIntegration::Team.new(
        'team6',
        ['john.doe@gmail.com', 'james.bond@gmail.com', 'john.wayne@gmail.com'],
        ['team6'],
        '6')
    end
    let(:server_teams) { [server_team1, server_team2, server_team6] }

    let(:toggl_members_repo) do
      members = [
        TogglIntegration::Member.new(emails: ['john.doe@gmail.com'], toggl_id: '1'),
        TogglIntegration::Member.new(emails: ['john.wayne@gmail.com'], toggl_id: '2'),
        TogglIntegration::Member.new(emails: ['james.bond@gmail.com'], toggl_id: '3'),
      ]
      TogglIntegration::MemberRepository.new(all: members)
    end
    let(:local_members_repo) do
      members = [
        TogglIntegration::Member.new(
          emails: ['john.doe@gmail.com', 'john.doe@yahoo.com'], repo_id: 'john.doe'),
        TogglIntegration::Member.new(emails: ['john.wayne@gmail.com'], repo_id: 'john.wayne'),
        TogglIntegration::Member.new(emails: ['james.bond@gmail.com'], repo_id: 'james.bond'),
        TogglIntegration::Member.new(emails: ['winnetou@gmail.com'], repo_id: 'winnetou'),
      ]
      TogglIntegration::MemberRepository.new(all: members)
    end

    let(:diff) do
      described_class.new(local_teams, server_teams, local_members_repo, toggl_members_repo)
    end

    it 'returns hash with differences' do
      diff_result = diff.call
      expect(diff_result).to be_a(Hash)
    end

    it 'returns list of members to add' do
      diff_result = diff.call
      expect(diff_result[:add_members].size).to eq 1
      expect(diff_result[:add_members][server_team1][0].emails).to eq ['james.bond@gmail.com']
    end

    it 'returns list of members to remove' do
      diff_result = diff.call
      expect(diff_result[:remove_members].size).to eq 1
      expect(diff_result[:remove_members][server_team2][0].emails).to eq ['john.wayne@gmail.com']
    end

    it 'returns list of teams to create' do
      diff_result = diff.call
      expect(diff_result[:create_teams].size).to eq 3
      expect(diff_result[:create_teams][local_team3]).not_to be_nil
      expect(diff_result[:create_teams][local_team4]).not_to be_nil
      expect(diff_result[:create_teams][local_team5]).not_to be_nil
    end

    it 'returns list of missing teams' do
      diff_result = diff.call
      expect(diff_result[:missing_teams]).to eq [server_team6]
    end

    it 'returns list of errors' do
      diff.call
      expect(diff.errors.count).to eq(2)
      expect(diff.errors[0]).to include('User lucky.luke was not found')
      expect(diff.errors[1]).to include('User winnetou has no account')
    end
  end
end
