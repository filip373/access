require 'rails_helper'

RSpec.describe JiraIntegration::Actions::Log do
  describe '.call' do
    subject(:log) { described_class.call(diff) }
    let(:diff) do
      {
        add_members: {
          'AG': {
            developers: %w(dev.first),
          },
          'DG': {
            developers: %w(dev.third),
          },
        },
        remove_members: {
          'AG': {
            developers: %w(dev.third),
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
    it { is_expected.to include '[api] add member dev.first to role developers in project AG' }
    it { is_expected.to include '[api] add member dev.third to role developers in project DG' }
    it { is_expected.to include '[api] remove member dev.third from role developers in project AG' }
    it { is_expected.to include '[api] remove member qa.first from role qas in project AG' }
    it { is_expected.to include '[api] remove member dev.first from role developers in project DG' }
    it { is_expected.to include '[api] remove member pm.first from role pms in project PEM' }
  end
end
