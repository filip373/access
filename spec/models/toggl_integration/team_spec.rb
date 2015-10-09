require 'rails_helper'

describe TogglIntegration::Team do
  describe '#to_yaml' do
    it 'returns new team with members' do
      team = TogglIntegration::Team.new('Team1',
                                        %w(john.doe jane.kovalsky),
                                        ['Team1'])
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
