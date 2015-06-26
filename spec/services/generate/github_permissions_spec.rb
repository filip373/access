require 'rails_helper'

describe Generate::GithubPermissions do
  include_context 'gh_api'

  describe '.new' do
    let(:instantiated_user) do
      described_class.new(
        instance_double('GithubApi'),
        Rails.root.join('path'),
      )
    end

    it { expect { instantiated_user.gh_api }.to raise_error(NoMethodError) }
    it { expect { instantiated_user.permissions_dir }.to raise_error(NoMethodError) }
  end

  describe '#call' do
    let(:permissions_dir) { Rails.root.join('spec/tmp/permissions') }
    let(:github_teams_dir) { permissions_dir.join('github_teams') }

    let(:team1_path) { github_teams_dir.join('team1.yml') }

    let(:team1_yaml) { YAML.load(File.open(team1_path)) }

    before do
      described_class.new(gh_api, permissions_dir).call
    end

    after do
      FileUtils.rm_rf(permissions_dir)
    end

    it 'creates file with team1' do
      expect(File.exist?(team1_path)).to be_truthy
    end

    it 'creates yaml file with permission attribute' do
      expect(team1_yaml['permission']).to be_present
    end

    it 'creates yaml file with members attribute' do
      expect(team1_yaml['members']).to be_present
      expect(team1_yaml['members']).to be_a Array
      expect(team1_yaml['members']).to_not be_empty
      expect(team1_yaml['members']).to include 'first.mbr'
    end

    it 'creates yaml file with repos attribute' do
      expect(team1_yaml['repos']).to be_present
      expect(team1_yaml['repos']).to be_a Array
      expect(team1_yaml['repos']).to_not be_empty
      expect(team1_yaml['repos']).to include 'first-repo'
    end
  end
end
