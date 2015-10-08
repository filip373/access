require 'rails_helper'

describe TogglIntegration::Team do
  include_context 'toggl_api'

  before do
    repo = double(:user_repository)
    allow(UserRepository).to receive(:new) { repo }

    allow(repo).to receive(:find_by_email)
      .with(member1['email']) { OpenStruct.new(id: 'john.doe') }
    allow(repo).to receive(:find_by_email)
      .with(member2['email']) { OpenStruct.new(id: 'jane.kovalsky') }
    allow(repo).to receive(:find_by_email)
      .with(member3['email']) { OpenStruct.new(id: 'james.bond') }
  end

  describe '.from_api_request' do
    it 'returns new team with members' do
      team = TogglIntegration::Team.from_api_request(toggl_api, team1)
      expect(team.id).to eq team1['id']
      expect(team.name).to eq team1['name']
      expect(team.projects).to eq [team1['name']]
      expect(team.members).to eq(['john.doe', 'jane.kovalsky'])

      team = TogglIntegration::Team.from_api_request(toggl_api, team2)
      expect(team.id).to eq team2['id']
      expect(team.name).to eq team2['name']
      expect(team.projects).to eq [team2['name']]
      expect(team.members).to eq(['james.bond'])
    end
  end

  describe '#to_yaml' do
    it 'returns new team with members' do
      team = TogglIntegration::Team.from_api_request(toggl_api, team1)
      expect(team.to_yaml).to eq(
        <<-EOS
---
name: Team1
members:
- john.doe
- jane.kovalsky
projects:
- Team1
EOS
      )
    end
  end
end
