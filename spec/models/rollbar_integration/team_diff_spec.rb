require 'rails_helper'

RSpec.describe RollbarIntegration::TeamDiff do
  include_context 'rollbar_api'
  include_context 'data_guru'

  before(:each) do
    Celluloid.shutdown
    Celluloid.boot
    allow(RollbarIntegration::Api).to receive(:new).and_return(rollbar_api)
    allow(DataGuru::Client).to receive(:new).and_return(data_guru)
  end

  let(:yaml_team1) { expected_teams.find { |t| t.name == 'team1' } }
  let(:yaml_new_team) { expected_teams.find { |t| t.name == 'new_team' } }
  let(:user_repo) { UserRepository.new(data_guru.members) }
  let(:rb_teams) { RollbarIntegration::Team.from_api_request(rollbar_api, team1, user_repo) }
  let(:rb_team1) { RollbarIntegration::Team.add_projects([rb_teams], rollbar_api).first }
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
        team_diff = described_class.new(yaml_team1, rb_team1, diff_hash, user_repo)
        expect(team_diff).to be_alive
      end

      it 'call blk' do
        team_diff = described_class.new(yaml_team1, rb_team1, diff_hash, user_repo)
        allow(blk).to receive(:call)
        team_diff.diff(blk)
        expect(blk).to have_received(:call)
      end

      it 'works in another thread' do
        team_diff = described_class.new(yaml_team1, rb_team1, diff_hash, user_repo)
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
        team_diff = described_class.new(yaml_team1, rb_team1, diff_hash, user_repo)
        team_diff.async.diff(blk)
        errors = condition.wait
        expect(errors).to_not be_empty
        expect(errors.count).to eq(1)
      end

      describe 'diff hash values' do
        context 'remove_projects key - there is one project less in yaml than in server' do
          let(:project3) do
            OpenStruct.new(
              id: 2,
              name: 'project3',
            )
          end
          let(:existing_projects) { [project1, project2, project3] }

          before do
            team_diff = described_class.new(yaml_team1, rb_team1, diff_hash, user_repo)
            team_diff.diff(blk)
          end

          it 'removes projects' do
            expect(diff_hash[:remove_projects][rb_team1]).to_not be_empty
          end

          it 'adds to remove_projects extra project' do
            expect(diff_hash[:remove_projects][rb_team1]).to eq('project3' => project3)
          end

          it 'contains projects with ID attribute' do
            expect(diff_hash[:remove_projects][rb_team1].values.first).to respond_to(:id)
          end
        end

        context 'add_projects key - there is one project more in yaml than in server' do
          let(:existing_projects) { [project1] }

          before do
            team_diff = described_class.new(yaml_team1, rb_team1, diff_hash, user_repo)
            team_diff.diff(blk)
          end

          it 'adds projects' do
            expect(diff_hash[:add_projects][rb_team1]).to_not be_empty
            expect(diff_hash[:add_projects][rb_team1]).to be_a Hash
          end

          it 'contains projects with ID attribute' do
            expect(diff_hash[:add_projects][rb_team1].values.first).to respond_to(:id)
          end

          it 'contains project with project name as key of hash' do
            expect(diff_hash[:add_projects][rb_team1].keys.first).to eq('project2')
          end
        end

        context 'add_members key - there is one member more in yaml than in server' do
          let(:existing_members) { [member1] }

          before do
            team_diff = described_class.new(yaml_team1, rb_team1, diff_hash, user_repo)
            team_diff.diff(blk)
          end

          it { expect(diff_hash[:add_members][rb_team1]).to_not be_empty }
          it { expect(diff_hash[:add_members][rb_team1]).to be_a Hash }

          it 'contains new member with email attribute' do
            expect(diff_hash[:add_members][rb_team1].values.first).to respond_to(:emails)
          end

          it 'contains member with name as key of hash' do
            expect(diff_hash[:add_members][rb_team1].keys.first).to include('.')
          end
        end

        context 'remove_members key - there is one member less in yaml than in server' do
          let(:existing_members) { [member1, member2, member3] }

          before do
            team_diff = described_class.new(yaml_team1, rb_team1, diff_hash, user_repo)
            team_diff.diff(blk)
          end

          it { expect(diff_hash[:remove_members][rb_team1]).to_not be_empty }
          it { expect(diff_hash[:remove_members][rb_team1]).to be_a Hash }

          it 'contains member with id attribute' do
            expect(diff_hash[:remove_members][rb_team1].values.first).to respond_to(:id)
          end

          it 'contains member with name as key of hash' do
            expect(diff_hash[:remove_members][rb_team1].keys.first).to include('.')
          end
        end

        context 'create_teams - there is a team in yaml which does not exist in server' do
          let(:existing_teams) { [rb_team1] }

          before do
            team_diff = described_class.new(yaml_new_team, nil, diff_hash, user_repo)
            team_diff.diff(blk)
          end
          it { expect(diff_hash[:create_teams][yaml_new_team]).to_not be_empty }
          it { expect(diff_hash[:create_teams][yaml_new_team]).to be_a Hash }

          context 'add_members key' do
            subject { diff_hash[:create_teams][yaml_new_team][:add_members] }

            it 'contains members with email attribute' do
              expect(subject.values.first).to respond_to(:emails)
            end

            it 'contains members with name as key of hash' do
              expect(subject.keys.first).to include('')
            end
          end

          context 'add_projects key' do
            subject { diff_hash[:create_teams][yaml_new_team][:add_projects] }
            it 'contains projects with ID attribute' do
              expect(subject.values.first).to respond_to(:id)
            end

            it 'contains projects with project name as key of hash' do
              expect(subject.keys.first).to eq('project2')
            end
          end
        end
      end
    end
  end
end
