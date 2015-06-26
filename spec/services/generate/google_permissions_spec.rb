require 'rails_helper'

describe Generate::GooglePermissions do
  include_context 'google_api'

  describe '.new' do
    let(:instantiated_user) do
      described_class.new(
        instance_double('google_groups'),
        Rails.root.join('path'),
      )
    end

    it { expect { instantiated_user.google_groups }.to raise_error(NoMethodError) }
    it { expect { instantiated_user.permissions_dir }.to raise_error(NoMethodError) }
  end

  describe '#call' do
    let(:permissions_dir) { Rails.root.join('spec/tmp/permissions') }
    let(:google_groups_dir) { permissions_dir.join('google_groups') }
    let(:google_groups) { google_api.list_groups_full_info }
    let(:group1_path) { google_groups_dir.join('group1.yml') }

    let(:group1_yaml) { YAML.load(File.open(group1_path)) }

    before do
      described_class.new(google_groups, permissions_dir).call
    end

    after do
      FileUtils.rm_rf(permissions_dir)
    end

    it 'creates file with team1' do
      expect(File.exist?(group1_path)).to be_truthy
    end

    it 'creates yaml file with permission attribute' do
      expect(group1_yaml['domain_membership']).to be_falsy
    end

    it 'creates yaml file with privacy attribute' do
      expect(group1_yaml['privacy']).to be_present
    end

    it 'creates yaml file with archive attribute' do
      expect(group1_yaml['archive']).to be_falsy
    end

    it 'creates yaml file with members attribute' do
      expect(group1_yaml['members']).to be_present
      expect(group1_yaml['members']).to be_a Array
      expect(group1_yaml['members']).to_not be_empty
      expect(group1_yaml['members']).to include 'first.member'
      expect(group1_yaml['members']).to include 'fourth'
    end

    it 'creates yaml file with aliases attribute' do
      expect(group1_yaml['aliases']).to be_present
      expect(group1_yaml['aliases']).to be_a Array
      expect(group1_yaml['aliases']).to_not be_empty
      expect(group1_yaml['aliases']).to include 'alias1'
    end
  end
end
