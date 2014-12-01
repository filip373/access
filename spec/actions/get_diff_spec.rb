require 'spec_helper'
require 'rails_helper'
require_relative '../../app/models/github_integration/actions/get_diff'
require_relative '../../app/models/github_integration/teams'
require 'ostruct'


RSpec.describe GithubIntegration::Actions::GetDiff do
  let(:expected_teams) { GithubIntegration::Teams.all }
  let(:team1) { Hashie::Mash.new({ name: 'team1', id: 1, members: [login: 'frst.mbr'], repos: [name: 'first-repo'], permissions: 'pull' }) }
  let(:new_team) { GithubIntegration::Team.new('team2', ['first.member'], ['first-repo'], 'push') } # => spec/get_diff_ymls/github_teams/team2.yml
  let(:existing_teams) { [team1] }
  let(:gh_api) do
    api = OpenStruct.new
    api.client = {}
    api.organizations = {}
    api.teams = {}
    api.stub_chain(:client, :organizations, :teams, :list_members) do |arg|
      existing_teams[arg-1].members
    end

    api.stub_chain(:client, :organizations, :teams, :list_repos) do |arg|
      existing_teams[arg-1].repos
    end

    api.stub(:teams).and_return(existing_teams)
    api
  end

  subject { described_class.new(expected_teams, gh_api).now! }

  it { is_expected.to be_a Hash }

  context 'existing team' do
    it { expect(subject[:add_members][team1][:members]).to eq ['scnd.mbr'] }
    it { expect(subject[:remove_members][team1][:members]).to eq ['frst.mbr'] }
    it { expect(subject[:add_repos][team1][:repos]).to eq ['second-repo'] }
    it { expect(subject[:remove_repos][team1][:repos]).to eq ['first-repo'] }
    it { expect(subject[:change_permissions][team1][:permissions]).to eq 'push' }
  end

  context 'new team' do
    it { expect(subject[:create_teams][new_team][:add_members]).to eq ['frst.mbr'] }
    it { expect(subject[:create_teams][new_team][:add_repos]).to eq ['first-repo'] }
    it { expect(subject[:create_teams][new_team][:add_permissions]).to eq 'push' }
  end

end
