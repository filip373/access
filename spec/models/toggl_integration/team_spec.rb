require 'rails_helper'

describe TogglIntegration::Team do
  describe '#to_yaml' do
    it 'returns new team with members' do
      team = described_class.new(
        name: 'Team1',
        members: [
          TogglIntegration::Member.new(emails: ['john.doe@gmail.com'],
                                       id: 'john.doe'),
          TogglIntegration::Member.new(emails: ['jane.kovalsky@gmail.com'],
                                       id: 'jane.kovalsky'),
        ],
        projects: ['Team1'],
        tasks: [],
      )
      expect(team.to_yaml).to eq(
        <<-EOS
---
name: Team1
members:
- john.doe
- jane.kovalsky
tasks: []
projects:
- Team1
EOS
      )
    end
  end
end
