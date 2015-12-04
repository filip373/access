require 'rails_helper'

RSpec.describe TogglIntegration::Actions::Log do
  let(:team) do
    TogglIntegration::Team.new(name: 'Team', members: ['john.doe'], projects: ['Team'], tasks: [])
  end
  let(:new_team) do
    TogglIntegration::Team.new(name: 'NewTeam',
                               members: ['john.doe'],
                               projects: ['NewTeam'],
                               tasks: [])
  end
  let(:task_1) { TogglIntegration::Task.new(name: 'Task_1', pid: 1) }
  let(:task_2) { TogglIntegration::Task.new(name: 'Task_2', pid: 2) }
  let(:task_3) { TogglIntegration::Task.new(name: 'Task_3', pid: 3) }
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
      remove_members: {
        team => [
          TogglIntegration::Member.new(emails: ['remove.him@gmail.com'], toggl_id: nil),
          TogglIntegration::Member.new(emails: ['remove.her@gmail.com'], toggl_id: nil),
        ],
      },
      deactivate_members: [TogglIntegration::Member.new(emails: ['second.dude@gmail.com'])],
      create_tasks: {
        team => [task_1, task_2],
      },
      remove_tasks: {
        team => [task_3],
      },
    }
  end

  let(:empty_diff) do
    {
      create_teams: {},
      add_members: {},
      remove_members: {},
      deactivate_members: [],
      create_tasks: {},
      remove_tasks: {},
    }
  end

  subject { described_class.new(diff).call }

  it { is_expected.to be_a Array }

  # rubocop:disable Metrics/LineLength
  context 'with changes' do
    it { is_expected.to satisfy { |s| s.size == 11 } }
    it { is_expected.to include "[api] create team #{new_team.name}" }
    it { is_expected.to include "[api] add member #{diff[:create_teams][new_team][0].default_email} to team #{new_team.name}" }
    it { is_expected.to include "[api] add member #{diff[:add_members][team][0].default_email} to team #{team.name}" }
    it { is_expected.to include "[api] remove member #{diff[:remove_members][team][0].default_email} from team #{team.name}" }
    it { is_expected.to include "[api] remove member #{diff[:remove_members][team][1].default_email} from team #{team.name}" }
    it { is_expected.to include "[api] invite member #{diff[:add_members][team][1].default_email} to team #{team.name}" }
    it { is_expected.to include "[api] deactivate member #{diff[:deactivate_members][0].default_email}" }

    it { is_expected.to include "[api] add task #{diff[:create_tasks][team][0].name} to team #{team.name}" }
    it { is_expected.to include "[api] add task #{diff[:create_tasks][team][1].name} to team #{team.name}" }

    it { is_expected.to include "[api] remove task #{diff[:remove_tasks][team][0].name} from team #{team.name}" }
  end
  # rubocop:enable Metrics/LineLength

  context 'without changes' do
    subject { described_class.new(empty_diff).call }

    it { is_expected.to satisfy { |s| s.size == 1 } }
    it { is_expected.to include 'There are no changes.' }
  end
end
