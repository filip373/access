require 'rails_helper'

RSpec.describe GoogleIntegration::Actions::CreateAccounts do
  include_context 'google_api'
  include_context 'data_guru'

  let(:accounts) { ['first.member', 'second.member'] }
  let(:user_repo) { UserRepository.new(data_guru.members) }
  let(:create_accounts_params) do
    [
      {
        first_name: 'First',
        last_name: 'Member',
        email: 'first.member@netguru.pl',
        password: 'abcdefgh',
        login: 'first.member',
      },
      {
        first_name: 'Second',
        last_name: 'Member',
        email: 'second.member@netguru.pl',
        password: 'abcdefgh',
        login: 'second.member',
      },
    ]
  end
  subject { described_class.new(google_api, user_repo).now!(accounts) }
  before do
    allow_any_instance_of(described_class).to receive(:sleep)
    allow(DataGuru::Client).to receive(:new).and_return(data_guru)
    allow(SecureRandom).to receive(:hex).and_return('abcdefgh')
  end
  it { is_expected.to be_a Hash }
  it { is_expected.to_not be_empty }
  it { expect(subject.count).to eq(2) }
  it { expect(subject[accounts.first][:codes]).to eq(%w(a b c)) }
  it { expect(subject[accounts.first][:email]).to eq('first.member@netguru.pl') }
  it { expect(subject[accounts.first][:last_name]).to eq('Member') }
  it { expect(subject[accounts.first][:first_name]).to eq('First') }

  it 'calls api with params' do
    expect(google_api).to receive(:create_user).with(create_accounts_params[0])
    expect(google_api).to receive(:create_user).with(create_accounts_params[1])
    subject
  end
end
