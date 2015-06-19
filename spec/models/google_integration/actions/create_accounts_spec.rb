require 'rails_helper'

RSpec.describe GoogleIntegration::Actions::CreateAccounts do
  include_context 'google_api'

  let(:accounts) { ['first.member', 'second.member'] }
  subject { described_class.new(google_api).now!(accounts) }
  before { allow_any_instance_of(described_class).to receive(:sleep) }
  it { is_expected.to be_a Hash }
  it { is_expected.to_not be_empty }
  it { expect(subject.count).to eq(2) }
  it { expect(subject[accounts.first][:codes]).to eq(%w(a b c)) }
  it { expect(subject[accounts.first][:email]).to eq('first.member@netguru.pl') }
  it { expect(subject[accounts.first][:last_name]).to eq('Member') }
  it { expect(subject[accounts.first][:first_name]).to eq('First') }
end
