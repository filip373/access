require 'rails_helper'

RSpec.describe RollbarIntegration::TeamDiff do
  include_context 'rollbar_api'

  before(:each) do
    Celluloid.shutdown
    Celluloid.boot
  end

  let(:yaml_teams) { RollbarIntegration::Teams.all }

  let(:yaml_team1) { yaml_teams.find { |t| t.name == 'team1' } }
  let(:diff_hash) do
    {
      create_teams: {},
      add_members: {},
      remove_members: {},
      add_projects: {},
      remove_projects: {},
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
        team_diff = described_class.new(yaml_team1, team1, rollbar_api, diff_hash)
        expect(team_diff).to be_alive
      end

      it 'call blk' do
        team_diff = described_class.new(yaml_team1, team1, rollbar_api, diff_hash)
        allow(blk).to receive(:call)
        team_diff.diff(blk)
        expect(blk).to have_received(:call)
      end

      it 'works in another thread' do
        team_diff = described_class.new(yaml_team1, team1, rollbar_api, diff_hash)
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
        team_diff = described_class.new(yaml_team1, team1, rollbar_api, diff_hash)
        team_diff.async.diff(blk)
        errors = condition.wait
        expect(errors).to_not be_empty
        expect(errors.count).to eq(1)
      end

      context 'there is one project less in yaml than in server' do
        let(:project3) do
          Hashie::Mash.new(
            id: 2,
            name: 'project3',
          )
        end
        let(:existing_projects) { [project1, project2, project3] }

        before do
          team_diff = described_class.new(yaml_team1, team1, rollbar_api, diff_hash)
          team_diff.diff(blk)
        end

        it 'remove projects' do
          expect(diff_hash[:remove_projects][team1]).to_not be_empty
        end

        it 'adds to remove_projects extra project' do
          expect(diff_hash[:remove_projects][team1]).to eq(%w(project3))
        end
      end

      context 'there is one project more in yaml than in server' do
        let(:existing_projects) { [project1] }

        before do
          team_diff = described_class.new(yaml_team1, team1, rollbar_api, diff_hash)
          team_diff.diff(blk)
        end

        it 'remove projects' do
          expect(diff_hash[:add_projects][team1]).to_not be_empty
        end

        it 'adds to remove_projects extra project' do
          expect(diff_hash[:add_projects][team1]).to eq(%w(project2))
        end
      end
    end
  end
end
