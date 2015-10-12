require 'rails_helper'

describe TogglIntegration::Team do
  describe '#to_yaml' do
    it 'returns new team with members' do
      team = TogglIntegration::Team.new(
        'Team1',
        [
          TogglIntegration::Member.new(emails: ['john.doe@gmail.com'],
                                       repo_id: 'john.doe'),
          TogglIntegration::Member.new(emails: ['jane.kovalsky@gmail.com'],
                                       repo_id: 'jane.kovalsky'),
        ],
        ['Team1'],
      )
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
