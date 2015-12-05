require 'rails_helper'

describe TogglIntegration::Actions::CleanupTeams do
  let(:toggl_api) { double(:toggl_api) }
  let(:task) { TogglIntegration::Task.new(name: 'Task_1', pid: '1') }
  let(:team1) do
    TogglIntegration::Team.new(name: 'Team1',
                               members: ['john.doe'],
                               projects: ['Team1'],
                               tasks: [task],
                               id: '1')
  end
  let(:team2) do
    TogglIntegration::Team.new(name: 'Team1',
                               members: ['john.doe'],
                               projects: ['Team1'],
                               tasks: [],
                               id: '1')
  end
  let(:server_teams) { [team1, team2] }
  let(:cleanup_teams) { described_class.new(server_teams, toggl_api) }

  describe '#call' do
    it 'calls api deactivate_team method' do
      expect(toggl_api).to receive(:deactivate_team).with(team1.id)
      expect(toggl_api).to receive(:deactivate_team).with(team2.id)
      cleanup_teams.call
    end
  end
end
