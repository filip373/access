require 'rails_helper'

describe TogglIntegration::TeamRepository do
  include_context 'toggl_api'

  describe '.build_from_data_guru' do
    let(:dg_client) { double(:dg_client, toggl_teams: []) }
    let(:member_repo) { double(:member_repo, find: []) }
    let(:toggl_members_repo) { double(:member_repo, find_by_emails: []) }

    it 'creates a repo object' do
      expect(described_class.build_from_data_guru(dg_client, member_repo, toggl_members_repo))
        .to be_an_instance_of(described_class)
    end
  end

  describe '.build_from_toggl_api' do
    let(:user_repo) { double(:user_repo) }
    let(:team_repo) { described_class.build_from_toggl_api(toggl_api, user_repo) }

    before do
      allow(user_repo).to receive(:find_by_email)
        .with(member1['email']) { OpenStruct.new(id: 'john.doe') }
      allow(user_repo).to receive(:find_by_email)
        .with(member2['email']) { OpenStruct.new(id: 'jane.kovalsky') }
      allow(user_repo).to receive(:find_by_email)
        .with(member3['email']) { OpenStruct.new(id: 'james.bond') }
      allow(team_repo).to receive(:list_all_tasks) { [] }
    end

    it 'creates a repo object' do
      expect(team_repo).to be_an_instance_of(described_class)
    end

    it 'creates as many teams as in api' do
      expect(team_repo.all.count).to eq all_teams.count
    end

    it 'initializes objects properly' do
      team = team_repo.all.first
      expect(team.id).to eq team1['id']
      expect(team.name).to eq team1['name']
      expect(team.projects).to eq [team1['name']]
      expect(team.members).to eq([
        TogglIntegration::Member.new(
          emails: ['email_1@gmail.com'], id: 'john.doe', toggl_id: 1),
        TogglIntegration::Member.new(
          emails: ['email_2@gmail.com'], id: 'jane.kovalsky', toggl_id: 2),
      ])
    end
  end
end
