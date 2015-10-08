require 'rails_helper'

RSpec.describe TogglIntegration::Actions::Log do
  let(:team) { TogglIntegration::Team.new('Team', ['john.doe'], ['Team']) }
  let(:new_team) { TogglIntegration::Team.new('NewTeam', ['john.doe'], ['NewTeam']) }
  let(:diff) do
    {
      create_teams: {
        new_team => {
          add_members: ['new.dude'],
        },
      },
      add_members: {
        team => ['first.dude'],
      },
      remove_members: {
        team => ['second.dude'],
      },
    }
  end

  let(:empty_diff) do
    {
      create_teams: {},
      add_members: {},
      remove_members: {},
    }
  end

  subject { described_class.new(diff).call }
  it { is_expected.to be_a Array }

  # rubocop:disable Metrics/LineLength
  context 'with changes' do
    it { is_expected.to satisfy { |s| s.size == 4 } }
    it { is_expected.to include "[api] create team #{new_team.name}" }
    it { is_expected.to include "[api] add member #{diff[:create_teams][new_team][:add_members][0]} to team #{new_team.name}" }
    it { is_expected.to include "[api] add member #{diff[:add_members][team][0]} to team #{team.name}" }
    it { is_expected.to include "[api] remove member #{diff[:remove_members][team][0]} from team #{team.name}" }
  end
  # rubocop:enable Metrics/LineLength

  context 'without changes' do
    subject { described_class.new(empty_diff).call }

    it { is_expected.to satisfy { |s| s.size == 1 } }
    it { is_expected.to include 'There are no changes.' }
  end
end
