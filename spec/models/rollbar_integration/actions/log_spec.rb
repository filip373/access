require 'rails_helper'

RSpec.describe RollbarIntegration::Actions::Log do
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

  let(:empty_diff) do
    {
      create_teams: {},
      add_members: {},
      remove_members: {},
      add_projects: {},
      remove_projects: {},
    }
  end

  subject { described_class.new(diff).now! }
  it { is_expected.to be_a Array }

  # rubocop:disable Metrics/LineLength
  context 'with changes' do
    it { is_expected.to satisfy { |s| s.size == 7 } }
    it { is_expected.to include "[api] create team #{new_team.name}" }
    it { is_expected.to include "[api] add member #{diff[:create_teams][new_team][:add_members].values.first.email} to team #{new_team.name}" }
    it { is_expected.to include "[api] add project #{diff[:create_teams][new_team][:add_projects].values.first.name} to team #{new_team.name}" }
    it { is_expected.to include "[api] add member #{diff[:add_members][team].values.first.email} to team #{team.name}" }
    it { is_expected.to include "[api] remove member #{diff[:remove_members][team].values.first.email} from team #{team.name}" }
    it { is_expected.to include "[api] add project #{diff[:add_projects][team].values.first.name} to team #{team.name}" }
    it { is_expected.to include "[api] remove project #{diff[:remove_projects][team].values.first.name} from team #{team.name}" }
  end
  # rubocop:enable Metrics/LineLength

  context 'without changes' do
    subject { described_class.new(empty_diff).now! }

    it { is_expected.to satisfy { |s| s.size == 1 } }
    it { is_expected.to include 'There are no changes.' }
  end
end
