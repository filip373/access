require 'rails_helper'

module GoogleIntegration
  describe Defaults do
    it { expect(described_class.group.privacy).to eq 'open' }
    it { expect(described_class.group.archive).to eq false }
    it { expect(described_class.not_existing).to eq nil }
    it { expect(described_class.not_existing { 'passed_block' } ).to eq 'passed_block' }
  end
end
