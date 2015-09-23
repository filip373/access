require 'rails_helper'

RSpec.describe RollbarIntegration::Actions::Sync do
  include_context 'rollbar_api'

  let(:team) do
    Hashie::Mash.new name: 'team1',
                     projects: [name: 'first-project'],
                     members: [
                       { username: 'first_dude' },
                     ]
  end
  let(:new_team) do
    Hashie::Mash.new name: 'new team',
                     projects: [],
                     members: []
  end
  let(:existing_teams) { [team] }
  let(:diff) do
    {
      create_teams: {
        new_team => {
          add_members: ['new_dude'],
          add_projects: ['cool-new-project'],
        },
      },
      add_members: {
        team => ['added_dude'],
      },
      remove_members: {
        team => ['first_dude'],
      },
      add_projects: {
        team => ['added-project'],
      },
      remove_projects: {
        team => ['first-project'],
      },
      change_permissions: {
        team => 'pull',
      },
    }
  end

  before { described_class.new(rollbar_api).now!(diff) }

  it { expect(team.projects).to_not include(name: 'first-project') }
  it { expect(team.projects).to include(name: 'added-project') }
  it { expect(team.members).to include(username: 'added_dude') }
  it { expect(team.members).to_not include(username: 'first_dude') }

  let(:created_team) { existing_teams[1] }
  it { expect(created_team.name).to eq 'new team' }
  it { expect(created_team.projects).to include(name: 'cool-new-project') }
  it { expect(created_team.members).to include(username: 'new_dude') }
end
