require 'rails_helper'

describe GoogleWorkers::DiffWorker do
  include_context 'data_guru'
  include_context 'google_api'

  before(:each) do
    allow(GoogleIntegration::Api).to receive(:new).and_return(google_api)
    allow(DataGuru::Client).to receive(:new).and_return(data_guru)
  end

  let(:token) { 'some-random-token' }
  it { is_expected.to be_processed_in :default }

  it 'saves the status of performing diff' do
    subject.perform(token)
    expect(Rails.cache.read('google_performing_diff')).to eq(false)
  end

  it 'saves the diff in the cache' do
    subject.perform(token)
    expect(Rails.cache.read('google_calculated_diff')).not_to be_nil
    expect(Rails.cache.read('google_calculated_diff')).to be_a Hash
    expect(Rails.cache.read('google_calculated_diff')).not_to be_empty
  end
end
