require 'rails_helper'

describe TogglIntegration::Actions::Sync do
  let(:toggl_api) { double(:toggl_api) }
  let(:new_team1) { double(:new_team1) }
  let(:new_team2) { double(:new_team2) }
  let(:team1) { double(:team1) }
  let(:team2) { double(:team2) }
  let(:member1) { double(:member1) }
  let(:member2) { double(:member2) }
  let(:diffs) do
    {
      create_teams: { new_team1 => [member1], new_team2 => [member2] },
      add_members: { team1 => [member1, member2] },
      remove_members: { team2 => [member2] },
    }
  end
  let(:sync) { described_class.new(diffs, toggl_api) }

  describe '#call' do
    it 'calls respective toggl_api methods' do
      expect(toggl_api).to receive(:create_team)
        .with(new_team1)
        .and_return('name' => 'Team1', 'id' => '1')

      expect(toggl_api).to receive(:create_team)
        .with(new_team2)
        .and_return('name' => 'Team2', 'id' => '2')

      expect(toggl_api).to receive(:add_member_to_team).exactly(4).times
      expect(toggl_api).to receive(:remove_member_from_team).once
      sync.call
    end
  end
end
