require 'rails_helper'

describe Generate::TogglPermissions do
  include_context 'toggl_api'
  let(:repo) { UserRepository.new }

  before do
    allow(repo).to receive(:find_by_email)
      .with(member1['email']) { OpenStruct.new(id: 'john.doe') }
    allow(repo).to receive(:find_by_email)
      .with(member2['email']) { OpenStruct.new(id: 'jane.kovalsky') }
    allow(repo).to receive(:find_by_email)
      .with(member3['email']) { OpenStruct.new(id: 'james.bond') }
  end

  describe '#call' do
    let(:permissions_dir) { Rails.root.join('spec/tmp/permissions') }
    let(:toggl_teams_dir) { permissions_dir.join('toggl_teams') }

    let(:team1_path) { toggl_teams_dir.join('team1.yml') }

    let(:team1_yaml) { YAML.load(File.open(team1_path)) }

    before do
      described_class.new(toggl_api, permissions_dir).call
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
      expect(team1_yaml['name']).to eq 'Team1'
    end

    context 'team name contains spaces' do
      let(:team1) do
        Hashie::Mash.new(
          name: 'team1 with spaces',
          id: 1,
          account_id: 1,
        )
      end
      let(:team1_path) { toggl_teams_dir.join('team1_with_spaces.yml') }

      it 'creates yaml file with slugified filename' do
        expect(File.exist?(team1_path)).to be_truthy
      end

      it 'creates yaml file with name attribute' do
        expect(team1_yaml['name']).to eq 'team1 with spaces'
      end
    end
  end
end
