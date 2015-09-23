require 'rails_helper'

RSpec.describe GoogleIntegration::Actions::AccountsDiff do
  include_context 'google_api'

  subject { described_class.new(google_api).now! }

  it { is_expected.to be_a Array }
  it { is_expected.to_not be_nil }

  context 'Yml (sixth.member.yml) contains email (member6@..) with login different than filename' do
    it 'compare login from email' do
      expect(subject).to_not include 'sixth.member'
      expect(subject).to include 'member6@foo.pl'
    end
  end
end
