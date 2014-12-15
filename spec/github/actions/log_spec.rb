require 'spec_helper'
require 'rails_helper'
require Rails.root.join 'app/models/github_integration/actions/get_log'

RSpec.describe GithubIntegration::Actions::Log do
  let(:team) { Hashie::Mash.new name: 'team1', permission: 'push', fake: true }
  let(:new_team) { Hashie::Mash.new name: 'new team', permission: 'push', fake: true }
  let(:diff) do
    {
      create_teams: {
        new_team => {
          add_permissions: 'push',
          add_members: ['new.dude'],
          add_repos: ['cool-new-repo']
        }
      },
      add_members: {
        team => ['first.dude']
      },
      remove_members: {
        team => ['second.dude']
      },
      add_repos: {
        team => ['first_repo']
      },
      remove_repos: {
        team => ['second_repo']
      },
      change_permissions: {
        team => 'push'
      }
    }
  end

  let(:empty_diff) do
    {
      create_teams: {},
      add_members: {},
      remove_members: {},
      add_repos: {},
      remove_repos: {},
      change_permissions: {}
    }
  end

  subject { described_class.new(diff).now! }
  it { is_expected.to be_a Array }

  context 'with changes' do
    it { is_expected.to satisfy { |s| s.size == 9 } }
    it { is_expected.to include "[api] create team #{new_team.name}" }
    it { is_expected.to include "[api] add member #{diff[:create_teams][new_team][:add_members][0]} to team #{new_team.name}" }
    it { is_expected.to include "[api] add repo #{diff[:create_teams][new_team][:add_repos][0]} to team #{new_team.name}" }
    it { is_expected.to include "[api] add permission #{diff[:create_teams][new_team][:add_permissions]} to team #{new_team.name}" }
    it { is_expected.to include "[api] add member #{diff[:add_members][team][0]} to team #{team.name}" }
    it { is_expected.to include "[api] remove member #{diff[:remove_members][team][0]} from team #{team.name}" }
    it { is_expected.to include "[api] add repo #{diff[:add_repos][team][0]} to team #{team.name}" }
    it { is_expected.to include "[api] remove repo #{diff[:remove_repos][team][0]} from team #{team.name}" }
    it { is_expected.to include "[api] change permission #{team.name} - #{diff[:change_permissions][team]}" }
  end

  context 'without changes' do
    subject { described_class.new(empty_diff).now! }

    it { is_expected.to satisfy { |s| s.size == 1 } }
    it { is_expected.to include "There are no changes." }
  end
end
