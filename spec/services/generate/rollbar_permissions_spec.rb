require 'rails_helper'

describe Generate::RollbarPermissions do
  include_context 'rollbar_api'
  include_context 'data_guru'

  let(:user_repo) { UserRepository.new(data_guru.users) }

  before(:each) do
    allow(DataGuru::Client).to receive(:new).and_return(data_guru)
  end

  describe '.new' do
    let(:instantiated_user) do
      described_class.new(
        instance_double('rollbarApi'),
        Rails.root.join('path'),
        user_repo,
      )
    end

    it { expect { instantiated_user.rollbar_api }.to raise_error(NoMethodError) }
    it { expect { instantiated_user.permissions_dir }.to raise_error(NoMethodError) }
  end

  describe '#call' do
    let(:permissions_dir) { Rails.root.join('spec/tmp/permissions') }
    let(:rollbar_teams_dir) { permissions_dir.join('rollbar_teams') }

    let(:team1_path) { rollbar_teams_dir.join('team1.yml') }

    let(:team1_yaml) { YAML.load(File.open(team1_path)) }

    before do
      described_class.new(rollbar_api, permissions_dir, user_repo).call
    end

    after do
      FileUtils.rm_rf(permissions_dir)
    end

    it 'creates file with team1' do
      expect(File.exist?(team1_path)).to be_truthy
    end

    it 'creates yaml file with members attribute' do
      expect(team1_yaml['members']).to be_a Array
      expect(team1_yaml['members']).to_not be_empty
    end

    it 'creates yaml file with projects attribute' do
      expect(team1_yaml['projects']).to be_a Array
      expect(team1_yaml['projects']).to_not be_empty
    end

    it 'creates yaml file with name attribute' do
      expect(team1_yaml['name']).to eq 'team1'
    end

    context 'team name contains spaces' do
      let(:team1) do
        Hashie::Mash.new(
          name: 'team1 with spaces',
          id: 1,
          account_id: 1,
        )
      end
      let(:team1_path) { rollbar_teams_dir.join('team1_with_spaces.yml') }

      it 'creates yaml file with slugified filename' do
        expect(File.exist?(team1_path)).to be_truthy
      end

      it 'creates yaml file with name attribute' do
        expect(team1_yaml['name']).to eq 'team1 with spaces'
      end
    end
  end
end
