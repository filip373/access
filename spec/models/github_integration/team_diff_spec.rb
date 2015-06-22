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
      it 'is alive' do
        team_diff = described_class.new(expected_team1, team1, gh_api, diff_hash)
        expect(team_diff).to be_alive
      end

      it 'call blk' do
        team_diff = described_class.new(expected_team1, team1, gh_api, diff_hash)
        allow(blk).to receive(:call)
        team_diff.diff(blk)
        expect(blk).to have_received(:call)
      end

      it 'works in another thread' do
        team_diff = described_class.new(expected_team1, team1, gh_api, diff_hash)
        expect(diff_hash[:add_members]).to be_empty

        team_diff.async.diff(blk)

        expect(diff_hash[:add_members]).to be_empty
        wait_diff_result = condition.wait
        expect(wait_diff_result).to_not be_empty
      end

      it 'returns errors if there are users which not exist in users dir' do
        blk = lambda do |_diff, errors|
          condition.signal(errors)
        end
        team_diff = described_class.new(expected_team1, team1, gh_api, diff_hash)
        team_diff.async.diff(blk)
        errors = condition.wait
        expect(errors).to_not be_empty
        binding.pry if errors.count == 4
        expect(errors.count).to eq(1)
      end
    end
  end
end
