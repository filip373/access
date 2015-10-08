require 'rails_helper'

describe TogglIntegration::Actions::Diff do
  describe '#call' do
    let(:team1) { TogglIntegration::Team.new('team1', ['john.doe', 'james.bond'], ['team1']) }
    let(:team2) { TogglIntegration::Team.new('team2', ['john.doe', 'james.bond'], ['team2']) }
    let(:team3) { TogglIntegration::Team.new('team3', ['john.doe', 'james.bond'], ['team3']) }
    let(:team4) { TogglIntegration::Team.new('team4', ['john.doe'], ['team4']) }
    let(:local_teams) { [team1, team2, team3, team4] }

    let(:server_team1) { TogglIntegration::Team.new('team1', ['john.doe'], ['team1'], '1') }
    let(:server_team2) do
      TogglIntegration::Team.new(
        'team2', ['john.doe', 'james.bond', 'john.wayne'], ['team2'], '2')
    end
    let(:server_teams) { [server_team1, server_team2] }

    let(:toggl_api) { double(:toggl_api) }
    let(:diff) do
      diff = described_class.new(local_teams, toggl_api)
      allow(diff).to receive(:server_teams) { server_teams }
      diff
    end
    let(:diff_result) { diff.call }

    it 'returns hash with differences' do
      expect(diff_result).to be_a(Hash)
    end

    it 'returns list of members to add' do
      expect(diff_result[:add_members].size).to eq 1

      expect(diff_result[:add_members][server_team1]).to eq ['james.bond']
    end

    it 'returns list of members to remove' do
      expect(diff_result[:remove_members].size).to eq 1
      expect(diff_result[:remove_members][server_team2]).to eq ['john.wayne']
    end

    it 'returns list of teams to create' do
      expect(diff_result[:create_teams].size).to eq 2
      expect(diff_result[:create_teams].keys).to eq [team3, team4]
    end
  end
end
