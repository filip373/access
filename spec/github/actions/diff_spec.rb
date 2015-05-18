require 'rails_helper'

RSpec.describe GithubIntegration::Actions::Diff do
  let(:expected_teams) { GithubIntegration::Teams.all }
  let(:team1) { Hashie::Mash.new({ name: 'team1', id: 1, members: [login: 'frst.mbr'], repos: [name: 'first-repo'], permissions: 'pull' }) }
  let(:new_team) { GithubIntegration::Team.new('team2', ['first.member'], ['first-repo'], 'push') }
  let(:existing_teams) { [team1] }
  let(:gh_api) do
    double.tap do |api|
      api.stub(:list_teams).and_return(existing_teams)
      api.stub(:teams).and_return(existing_teams)
      api.stub(:list_team_members) do |arg|
        existing_teams[arg - 1].members
      end
      api.stub(:list_team_repos) do |arg|
        existing_teams[arg - 1].repos
      end
      api.stub(:team_member_pending?) do |team_id, user_name|
        true if team_id == 1 && user_name == 'thrd.mbr'
        false
      end
    end
  end

  subject { described_class.new(expected_teams, gh_api).now! }

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
end
