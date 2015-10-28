require 'rails_helper'

RSpec.describe TogglIntegration::Actions::Log do
  let(:team) { TogglIntegration::Team.new('Team', ['john.doe'], ['Team']) }
  let(:new_team) { TogglIntegration::Team.new('NewTeam', ['john.doe'], ['NewTeam']) }
  let(:diff) do
    {
      create_teams: {
        new_team => [TogglIntegration::Member.new(emails: ['john.doe@gmail.com'], toggl_id: 1)],
      },
      add_members: {
        team => [
          TogglIntegration::Member.new(emails: ['first.dude@gmail.com'], toggl_id: 2),
          TogglIntegration::Member.new(emails: ['second.dude@gmail.com'], toggl_id: nil),
        ],
      },
      deactivate_members: [TogglIntegration::Member.new(emails: ['second.dude@gmail.com'])],
    }
  end

  let(:empty_diff) do
    {
      create_teams: {},
      add_members: {},
      deactivate_members: [],
    }
  end

  subject { described_class.new(diff).call }
  it { is_expected.to be_a Array }

  # rubocop:disable Metrics/LineLength
  context 'with changes' do
    it { is_expected.to satisfy { |s| s.size == 5 } }
    it { is_expected.to include "[api] create team #{new_team.name}" }
    it { is_expected.to include "[api] add member #{diff[:create_teams][new_team][0].emails.first} to team #{new_team.name}" }
    it { is_expected.to include "[api] add member #{diff[:add_members][team][0].emails.first} to team #{team.name}" }
    it { is_expected.to include "[api] invite member #{diff[:add_members][team][1].emails.first} to team #{team.name}" }
    it { is_expected.to include "[api] deactivate member #{diff[:deactivate_members][0].emails.first}" }
  end
  # rubocop:enable Metrics/LineLength

  context 'without changes' do
    subject { described_class.new(empty_diff).call }

    it { is_expected.to satisfy { |s| s.size == 1 } }
    it { is_expected.to include 'There are no changes.' }
  end
end
