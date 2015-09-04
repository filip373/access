require 'rails_helper'

module GoogleIntegration
  describe GroupPrivacy do
    include_context 'google_api'

    describe '.from_bool' do
      context 'with "true"' do
        it 'makes group closed' do
          expect(described_class.from_bool(true)).to be_closed
          expect(described_class.from_bool(true)).to_not be_open
        end
      end

      context 'with "false"' do
        it 'makes group open' do
          expect(described_class.from_bool(false)).to be_open
          expect(described_class.from_bool(false)).to_not be_closed
        end
      end
    end
  end
end
