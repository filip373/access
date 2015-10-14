require 'rails_helper'

describe TogglIntegration::Actions::CleanupTeams do
  let(:toggl_api) { double(:toggl_api) }
  let(:team1) { TogglIntegration::Team.new('Team1', ['john.doe'], ['Team1'], '1') }
  let(:team2) { TogglIntegration::Team.new('Team1', ['john.doe'], ['Team1'], '1') }
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
