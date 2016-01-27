require 'rails_helper'

RSpec.describe JiraIntegration::Diffs::Projects do
  include_context 'data_guru'
  include_context 'jira_api'

  describe '.call' do
    subject(:diff) { described_class.call(jira_api, data_guru) }

    it 'calculates missing projects in Jira' do
      expect(diff.last).to eq(
        'AG' => { name: 'AccessGuru' },
      )
    end

    it 'calculates zombie projects in Jira' do
      expect(diff.first).to eq(
        'PER' => { name: 'Permissions' },
      )
    end
  end
end
