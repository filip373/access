require 'rails_helper'

describe TogglIntegration::Actions::Sync do
  let(:toggl_api) { double(:toggl_api) }
  let(:new_team1) { double(:new_team1) }
  let(:new_team2) { double(:new_team2) }
  let(:team1) { double(:team1, id: '1') }
  let(:team2) { double(:team2) }
  let(:member1) { double(:member1, toggl_id?: true) }
  let(:member2) { double(:member2, toggl_id?: true) }
  let(:member3) { double(:member3, toggl_id?: false, emails: ['john@doe.com'], id: 'jd') }
  let(:member4) { double(:member4, toggl_id?: true, emails: ['remove.him@google.com'], id: 'rh') }
  let(:task_1) { double(:task_1, name: 'task_1', pid: '1') }
  let(:task_2) { double(:task_2, name: 'task_2', pid: '2') }
  let(:task_3) { double(:task_3, name: 'task_3', pid: '3') }
  let(:diffs) do
    {
      create_teams: { new_team1 => [member1], new_team2 => [member2, member3] },
      add_members: { team1 => [member1, member2, member3] },
      remove_members: { team1 => [member4] },
      deactivate_members: Set.new([member2]),
      create_tasks: { team1 => [task_1, task_2] },
      remove_tasks: { team2 => [task_3] },
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

      expect(toggl_api).to receive(:add_task_to_project).twice

      expect(toggl_api).to receive(:remove_tasks_from_project)
        .with(["3"])
        .once

      expect(toggl_api).to receive(:add_member_to_team).exactly(6).times
      expect(toggl_api).to receive(:deactivate_member).once
      expect(toggl_api).to receive(:invite_member).and_return('uid' => 1).once
      expect(toggl_api).to receive(:remove_member_from_team).with(member4, team1).once

      sync.call
    end
  end
end
