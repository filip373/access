require 'rails_helper'

RSpec.describe GithubIntegration::TeamDiff do
  include_context 'gh_api'
  include_context 'data_guru'

  before(:each) do
    Celluloid.shutdown
    Celluloid.boot
    allow(DataGuru::Client).to receive(:new).and_return(data_guru)
  end

  let(:expected_teams) { GithubIntegration::Teams.all(data_guru.github_teams) }

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
  let(:user_repo) { UserRepository.new(data_guru.users) }

  describe '#diff' do
    context 'run asyncronisouly' do
      let(:blk) do
        lambda do |diff, _errors|
          condition.signal(diff)
        end
      end

      let(:condition) { Celluloid::Condition.new }
      it 'is alive' do
        team_diff = described_class.new(expected_team1, team1, gh_api, diff_hash, user_repo)
        expect(team_diff).to be_alive
      end

      it 'call blk' do
        team_diff = described_class.new(expected_team1, team1, gh_api, diff_hash, user_repo)
        allow(blk).to receive(:call)
        team_diff.diff(blk)
        expect(blk).to have_received(:call)
      end

      it 'works in another thread' do
        team_diff = described_class.new(expected_team1, team1, gh_api, diff_hash, user_repo)
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
        team_diff = described_class.new(expected_team1, team1, gh_api, diff_hash, user_repo)
        team_diff.async.diff(blk)
        errors = condition.wait
        expect(errors).to_not be_empty
        expect(errors.count).to eq(1)
      end
    end
  end
end
