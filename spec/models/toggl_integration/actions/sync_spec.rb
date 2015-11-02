require 'rails_helper'

describe TogglIntegration::Actions::Sync do
  let(:toggl_api) { double(:toggl_api) }
  let(:new_team1) { double(:new_team1) }
  let(:new_team2) { double(:new_team2) }
  let(:team1) { double(:team1) }
  let(:team2) { double(:team2) }
  let(:member1) { double(:member1, toggl_id?: true) }
  let(:member2) { double(:member2, toggl_id?: true) }
  let(:member3) { double(:member3, toggl_id?: false, emails: ['john@doe.com'], id: 'jd') }
  let(:diffs) do
    {
      create_teams: { new_team1 => [member1], new_team2 => [member2, member3] },
      add_members: { team1 => [member1, member2, member3] },
      deactivate_members: Set.new([member2]),
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

      expect(toggl_api).to receive(:add_member_to_team).exactly(6).times
      expect(toggl_api).to receive(:deactivate_member).once
      expect(toggl_api).to receive(:invite_member).and_return('uid' => 1).once
      sync.call
    end
  end
end
