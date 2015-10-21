require 'rails_helper'

RSpec.describe GithubIntegration::Actions::Diff do
  include_context 'gh_api'
  include_context 'data_guru'

  before(:each) do
    Celluloid.shutdown
    Celluloid.boot
    allow(DataGuru::Client).to receive(:new).and_return(data_guru)
    DataGuru::Client.new.users
  end

  let(:expected_teams) { GithubIntegration::Teams.all(data_guru.github_teams) }
  let(:new_team) do
    expected_teams.find { |team| team.name == 'team2' }
  end

  subject { described_class.new(expected_teams, existing_teams, gh_api).now! }

  it { is_expected.to be_a Hash }

  context 'existing team' do
    it { expect(subject[:add_members][team1]).to eq ['scnd.mbr'] }
    it { expect(subject[:remove_members][team1]).to eq ['first.mbr'] }
    it { expect(subject[:add_repos][team1]).to eq ['second-repo'] }
    it { expect(subject[:remove_repos][team1]).to eq ['first-repo'] }
    it { expect(subject[:change_permissions][team1]).to eq 'push' }
  end

  context 'new team' do
    it { expect(subject[:create_teams][new_team][:add_members]).to eq ['first.mbr'] }
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
