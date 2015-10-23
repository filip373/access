require 'rails_helper'

RSpec.describe GoogleIntegration::Actions::CreateAccounts do
  include_context 'google_api'
  include_context 'data_guru'

  let(:accounts) { ['first.member', 'second.member'] }
  let(:user_repo) { UserRepository.new(data_guru.users) }
  subject { described_class.new(google_api, user_repo).now!(accounts) }
  before do
    allow_any_instance_of(described_class).to receive(:sleep)
    allow(DataGuru::Client).to receive(:new).and_return(data_guru)
  end
  it { is_expected.to be_a Hash }
  it { is_expected.to_not be_empty }
  it { expect(subject.count).to eq(2) }
  it { expect(subject[accounts.first][:codes]).to eq(%w(a b c)) }
  it { expect(subject[accounts.first][:email]).to eq('first.member@netguru.pl') }
  it { expect(subject[accounts.first][:last_name]).to eq('Member') }
  it { expect(subject[accounts.first][:first_name]).to eq('First') }
end
