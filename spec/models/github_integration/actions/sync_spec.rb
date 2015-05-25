require 'rails_helper'

RSpec.describe GithubIntegration::Actions::Sync do
  let(:gh_api) do
    double.tap do |api|
      allow(api).to receive(:add_permission) do |permissions, team|
        team.permission = permissions
      end
      allow(api).to receive(:remove_repo) do |repo_name, team|
        team.repos.delete_if { |r| r.name == repo_name }
      end
      allow(api).to receive(:add_repo) do |repo_name, team|
        team.repos.push(Hashie::Mash.new name: repo_name)
      end
      allow(api).to receive(:add_member) do |member_login, team|
        team.members.push(Hashie::Mash.new login: member_login)
      end
      allow(api).to receive(:remove_member) do |member_login, team|
        team.members.delete_if { |m| m.login == member_login }
      end
      allow(api).to receive(:create_team) do
        existing_teams.push(new_team)
      end.and_yield(new_team)
    end
  end
  let(:team) do
    Hashie::Mash.new name: 'team1',
                     permission: 'push',
                     repos: [name: 'first-repo'],
                     members: [
                       { login: 'first_dude' },
                     ]
  end
  let(:new_team) do
    Hashie::Mash.new name: 'new team',
                     permissions: 'push',
                     repos: [],
                     members: []
  end
  let(:existing_teams) { [team] }
  let(:diff) do
    {
      create_teams: {
        new_team => {
          add_permissions: 'push',
          add_members: ['new_dude'],
          add_repos: ['cool-new-repo'],
        },
      },
      add_members: {
        team => ['added_dude'],
      },
      remove_members: {
        team => ['first_dude'],
      },
      add_repos: {
        team => ['added-repo'],
      },
      remove_repos: {
        team => ['first-repo'],
      },
      change_permissions: {
        team => 'pull',
      },
    }
  end

  before { described_class.new(gh_api).now!(diff) }

  it { expect(team.permission).to eq 'pull' }
  it { expect(team.repos).to_not include(name: 'first-repo') }
  it { expect(team.repos).to include(name: 'added-repo') }
  it { expect(team.members).to include(login: 'added_dude') }
  it { expect(team.members).to_not include(login: 'first_dude') }

  let(:created_team) { existing_teams[1] }
  it { expect(created_team.permission).to eq 'push' }
  it { expect(created_team.name).to eq 'new team' }
  it { expect(created_team.repos).to include(name: 'cool-new-repo') }
  it { expect(created_team.members).to include(login: 'new_dude') }
  it { expect(created_team.permission).to eq 'push' }
end
