require 'rails_helper'

describe Generate::RollbarPermissions do
  include_context 'rollbar_api'

  describe '.new' do
    let(:instantiated_user) do
      described_class.new(
        instance_double('rollbarApi'),
        Rails.root.join('path'),
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
      described_class.new(rollbar_api, permissions_dir).call
    end

    after do
      FileUtils.rm_rf(permissions_dir)
    end

    it 'creates file with team1' do
      expect(File.exist?(team1_path)).to be_truthy
    end

    it 'creates yaml file with members attribute' do
      expect(team1_yaml['members']).to be_present
      expect(team1_yaml['members']).to be_a Array
      expect(team1_yaml['members']).to_not be_empty
    end

    it 'creates yaml file with projects attribute' do
      expect(team1_yaml['projects']).to be_present
      expect(team1_yaml['projects']).to be_a Array
      expect(team1_yaml['projects']).to_not be_empty
    end
  end
end
