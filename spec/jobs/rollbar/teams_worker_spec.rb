require 'rails_helper'

describe RollbarWorkers::TeamsWorker do
  include_context 'data_guru'
  include_context 'rollbar_api'

  before(:each) do
    allow(RollbarIntegration::Api).to receive(:new).and_return(rollbar_api)
    allow(DataGuru::Client).to receive(:new).and_return(data_guru)
  end

  let(:token) { 'some-random-token' }
  it { is_expected.to be_processed_in :default }

  it 'saves the status of calculating teams' do
    subject.perform(token)
    expect(Rails.cache.read('rollbar_performing_teams')).to eq(false)
  end

  it 'saves the teams in the cache' do
    subject.perform(token)
    expect(Rails.cache.read('rollbar_calculated_teams')).not_to be_nil
    expect(Rails.cache.read('rollbar_calculated_teams')).to be_a Array
    expect(Rails.cache.read('rollbar_calculated_teams')).not_to be_empty
  end
end
