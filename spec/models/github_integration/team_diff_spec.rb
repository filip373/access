require 'rails_helper'

RSpec.describe GithubIntegration::TeamDiff do
  include_context 'gh_api'

  before(:each) do
    Celluloid.shutdown
    Celluloid.boot
  end

  let(:expected_teams) { GithubIntegration::Teams.all }

  let(:expected_team1) { expected_teams.find { |t| t.name == 'team1' } }
  let(:diff_hash) do
    {
      create_teams: {},
      add_members: {},
      remove_members: {},
      add_repos: {},
      remove_repos: {},
      change_permissions: {},
    }
  end

  describe '#diff' do
    context 'run asyncronisouly' do
      let(:blk) do
        lambda do |diff, _errors|
          condition.signal(diff)
        end
      end

      let(:condition) { Celluloid::Condition.new }
      let(:team_diff_observer) { GithubIntegration::Observers::TeamDiffObserver }
      it 'is alive' do
        team_diff = described_class.new(expected_team1, team1, gh_api)
        expect(team_diff).to be_alive
      end

      it 'works in another thread' do
        team_diff = described_class.new(expected_team1, team1, gh_api)
        expect(diff_hash[:add_members]).to be_empty
        team_diff.async.diff
        expect(diff_hash[:add_members]).to be_empty
      end

      it 'returns errors if there are users which not exist in users dir' do
        team_diff_observer.new(condition, 1)
        team_diff = described_class.new(expected_team1, team1, gh_api)
        team_diff.async.diff
        _diff, errors = condition.wait
        expect(errors).to_not be_empty
        expect(errors.count).to eq(1)
      end
    end
  end
end
