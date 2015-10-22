require 'rails_helper'

describe Generate::TogglPermissions do
  describe '#call' do
    let(:toggl_teams) do
      [
        TogglIntegration::Team.new(
          "team1",
          [
            TogglIntegration::Member.new(emails: ["john.doe@gmail.com"], repo_id: "john.doe"),
            TogglIntegration::Member.new(emails: ["james.bond@gmail.com"], repo_id: "james.bond")
          ],
          ["team1"]),
        TogglIntegration::Team.new(
          "team2 with spaces",
          [
            TogglIntegration::Member.new(emails: ["john.doe@gmail.com"], repo_id: "john.doe"),
            TogglIntegration::Member.new(emails: ["james.bond@gmail.com"], repo_id: "james.bond")
          ],
          ["team2 with spaces"])
      ]
    end
    let(:permissions_dir) { Rails.root.join('spec/tmp/permissions') }
    let(:toggl_teams_dir) { permissions_dir.join('toggl_teams') }

    let(:team1_path) { toggl_teams_dir.join('team1.yml') }
    let(:team2_path) { toggl_teams_dir.join('team2_with_spaces.yml') }

    let(:team1_yaml) { YAML.load(File.open(team1_path)) }
    let(:team2_yaml) { YAML.load(File.open(team2_path)) }

    before do
      described_class.new(toggl_teams, permissions_dir).call
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
      it 'creates yaml file with slugified filename' do
        expect(File.exist?(team2_path)).to be_truthy
      end

      it 'creates yaml file with name attribute' do
        expect(team2_yaml['name']).to eq 'team2 with spaces'
      end
    end
  end
end
