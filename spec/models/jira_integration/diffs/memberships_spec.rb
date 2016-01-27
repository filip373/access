require 'rails_helper'

RSpec.describe JiraIntegration::Diffs::Memberships do
  include_context 'data_guru'
  include_context 'jira_api'

  describe '.call' do
    subject { described_class.call(jira_api, data_guru) }

    it 'calculates members to add' do
      expect(subject.last).to eq(
        'AG' => {
          developers: %w(dev.first dev.second),
          qas: %w(qa.first),
        },
        'DG' => {
          developers: %w(dev.first),
          pms: %w(pm.second),
          clients: %w(external/client.first),
        },
      )
    end

    it 'calculates members to remove' do
      expect(subject.first).to eq(
        'AG' => {
          developers: %w(dev.third),
          qas: %w(qa.second),
        },
        'DG' => {
          qas: %w(qa.first),
          pms: %w(pm.first),
        },
      )
    end
  end
end
