require 'rails_helper'

RSpec.describe JiraIntegration::Actions::Diff do
  include_context 'data_guru'
  include_context 'jira_api'

  describe '.call' do
    subject(:diff) { described_class.call(jira_api, data_guru) }

    let(:memberships) do
      [
        { 'AG' => { developers: 'dev.first' } },
        { 'DG' => { developers: 'dev.first' } },
      ]
    end

    let(:projects) do
      [
        { 'PER' => { name: 'Permissions' } },
        { 'LAN' => { name: 'Lando' } },
      ]
    end

    before do
      allow(JiraIntegration::Diffs::Memberships).to receive(:call).and_return(memberships)
      allow(JiraIntegration::Diffs::Projects).to receive(:call).and_return(projects)
    end

    it 'constructs the diff hash' do
      expect(subject).to eq(
        add_members: memberships.last,
        remove_members: memberships.first,
        missing_projects: projects.last,
        zombie_projects: projects.first,
      )
    end
  end
end
