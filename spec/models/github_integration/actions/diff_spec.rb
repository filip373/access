require 'rails_helper'

RSpec.describe GithubIntegration::Actions::Diff do
  let(:expected_teams) { GithubIntegration::Teams.all }
  let(:team1) do
    Hashie::Mash.new(
      name: 'team1',
      id: 1,
      members: [login: 'frst.mbr'],
      repos: [
        { name: 'first-repo', owner: { id: 1 } },
        { name: 'first-repo', owner: { id: 2 } },
      ],
      permissions: 'pull',
    )
  end
  let(:team_empty) do
    Hashie::Mash.new(
      name: 'team_empty',
      id: 1,
      members: [login: 'frst.mbr'],
      repos: [
        { name: 'first-repo', owner: { id: 1 } },
        { name: 'first-repo', owner: { id: 2 } },
      ],
      permissions: 'pull',
    )
  end
  let(:new_team) do
    GithubIntegration::Team.new(
      'team2',
      ['first.member'],
      ['first-repo'],
      'push',
    )
  end
  let(:existing_teams) { [team1, team_empty] }
  let(:gh_api) do
    double.tap do |api|
      allow(api).to receive(:list_teams) { existing_teams }
      allow(api).to receive(:teams) { existing_teams }
      allow(api).to receive(:list_team_members) do |arg|
        existing_teams[arg - 1].members
      end
      allow(api).to receive(:list_team_repos) { |arg| existing_teams[arg - 1].repos }
      allow(api).to receive(:team_member_pending?) do |team_id, user_name|
        team_id == 1 && user_name == 'thrd.mbr'
      end
      allow(api).to receive(:find_organization_id) { 1 }
    end
  end

  before(:each) do
    Celluloid.shutdown
    Celluloid.boot
  end

  subject { described_class.new(expected_teams, existing_teams, gh_api).now! }

  it { is_expected.to be_a Hash }

  context 'existing team' do
    it { expect(subject[:add_members][team1]).to eq ['scnd.mbr'] }
    it { expect(subject[:remove_members][team1]).to eq ['frst.mbr'] }
    it { expect(subject[:add_repos][team1]).to eq ['second-repo'] }
    it { expect(subject[:remove_repos][team1]).to eq ['first-repo'] }
    it { expect(subject[:change_permissions][team1]).to eq 'push' }
  end

  context 'new team' do
    it { expect(subject[:create_teams][new_team][:add_members]).to eq ['frst.mbr'] }
    it { expect(subject[:create_teams][new_team][:add_repos]).to eq ['first-repo'] }
    it { expect(subject[:create_teams][new_team][:add_permissions]).to eq 'push' }
  end

  context 'members in yml is empty' do
    let(:empty_members) { expected_teams.find { |t| t.name == 'team_empty' }.members }
    it { expect(empty_members).to be_a Array }
    it { expect(empty_members).to be_empty }
  end

  context 'repos in yml is empty' do
    let(:empty_repos) { expected_teams.find { |t| t.name == 'team_empty' }.repos }
    it { expect(empty_repos).to be_a Array }
    it { expect(empty_repos).to be_empty }
  end
end
