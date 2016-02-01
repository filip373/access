require 'rails_helper'

RSpec.describe JiraIntegration::Actions::Log do
  describe '.call' do
    before do
      translations = {
        add_member: 'Add %{member} to %{role} in %{key}',
        remove_member: 'Remove %{member} from %{role} in %{key}',
      }
      I18n.backend.store_translations(:en, jira: translations)
    end

    subject(:log) { described_class.call(diff) }
    let(:diff) do
      {
        add_members: {
          'AG': {
            developers: %w(dev.first),
          },
          'DG': {
            developers: %w(dev.second),
          },
        },
        remove_members: {
          'AG': {
            developers: %w(dev.second),
            qas: %w(qa.first),
          },
          'DG': {
            developers: %w(dev.first),
          },
          'PEM': {
            pms: %w(pm.first),
          },
        },
      }
    end

    it { expect(subject.length).to eq 6 }
    it { is_expected.to include '[api] Add dev.first to developers in AG' }
    it { is_expected.to include '[api] Add dev.second to developers in DG' }
    it { is_expected.to include '[api] Remove dev.second from developers in AG' }
    it { is_expected.to include '[api] Remove qa.first from qas in AG' }
    it { is_expected.to include '[api] Remove dev.first from developers in DG' }
    it { is_expected.to include '[api] Remove pm.first from pms in PEM' }
  end
end
