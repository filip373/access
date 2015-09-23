require 'rails_helper'

RSpec.describe RollbarIntegration::Actions::Log do
  let(:team) { Hashie::Mash.new name: 'team1', fake: true }
  let(:new_team) { Hashie::Mash.new name: 'new team', fake: true }
  let(:diff) do
    {
      create_teams: {
        new_team => {
          add_members: ['member1@foo.pl'],
          add_projects: ['project1'],
        },
      },
      add_members: {
        team => ['member1@foo.pl'],
      },
      remove_members: {
        team => ['member2@foo.pl'],
      },
      add_projects: {
        team => ['first_project'],
      },
      remove_projects: {
        team => ['second_project'],
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
    it { is_expected.to include "[api] add member #{diff[:create_teams][new_team][:add_members][0]} to team #{new_team.name}" }
    it { is_expected.to include "[api] add project #{diff[:create_teams][new_team][:add_projects][0]} to team #{new_team.name}" }
    it { is_expected.to include "[api] add member #{diff[:add_members][team][0]} to team #{team.name}" }
    it { is_expected.to include "[api] remove member #{diff[:remove_members][team][0]} from team #{team.name}" }
    it { is_expected.to include "[api] add project #{diff[:add_projects][team][0]} to team #{team.name}" }
    it { is_expected.to include "[api] remove project #{diff[:remove_projects][team][0]} from team #{team.name}" }
  end
  # rubocop:enable Metrics/LineLength

  context 'without changes' do
    subject { described_class.new(empty_diff).now! }

    it { is_expected.to satisfy { |s| s.size == 1 } }
    it { is_expected.to include 'There are no changes.' }
  end
end
