require 'rails_helper'

RSpec.describe RollbarIntegration::Actions::Sync do
  include_context 'rollbar_api'

  let(:team) do
    Hashie::Mash.new name: 'team1',
                     id: 1,
                     projects: {
                       project1.name => project1,
                     },
                     members: {
                       member1.email => member1,
                     }
  end
  let(:new_team) do
    Hashie::Mash.new name: 'new team',
                     projects: {},
                     members: {}
  end
  let(:existing_teams) { [team] }
  let(:diff) do
    {
      create_teams: {
        new_team => {
          add_members: {
            member2.email => member2,
          },
          add_projects: {
            project2.name => project2,
          },
        },
      },
      add_members: {
        team => {
          member3.email => member3,
        },
      },
      remove_members: {
        team => {
          member1.email => member1,
        },
      },
      add_projects: {
        team => {
          project3.name => project3,
        },
      },
      remove_projects: {
        team => {
          project1.name => project1,
        },
      },
    }
  end

  before { described_class.new(rollbar_api).now!(diff) }

  it { expect(team.projects).to_not have_key(project1.name) }
  it { expect(team.projects).to have_key(project3.name) }
  it { expect(team.members).to have_key(member3.email) }
  it { expect(team.members).to_not have_key(member1.email) }

  let(:created_team) { existing_teams[1] }
  it { expect(created_team.name).to eq 'new team' }
  it { expect(created_team.projects).to have_key(project2.name) }
  it { expect(created_team.members).to have_key(member2.email) }
end
