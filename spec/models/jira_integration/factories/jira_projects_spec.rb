require 'rails_helper'

RSpec.describe JiraIntegration::Factories::JiraProjects do
  include_context 'jira_api'

  describe '.call' do
    subject(:jira_projects_factory) { described_class.call(jira_api, jira_api.projects) }
    let(:expected_projects) do
      {
        'AG' => {
          developers: %w(dev.third),
          qas: %w(qa.second),
          pms: %w(pm.first),
          client_developers: %w(external/clientdev.first),
          clients: %w(external/client.first),
        },
        'DG' => {
          developers: %w(dev.second),
          qas: %w(qa.first),
          pms: %w(pm.first),
          client_developers: %w(),
          clients: %w(),
        },
        'NFG' => {
          developers: %w(),
          qas: %w(),
          pms: %w(),
          client_developers: %w(),
          clients: %w(),
        },
      }
    end

    it { is_expected.to eq expected_projects }

    context 'it only maps the projects that are provided' do
      subject(:jira_projects_factory) { described_class.call(jira_api, jira_api.projects[0..1]) }

      it { is_expected.to eq expected_projects.except('NFG') }
    end
  end
end
