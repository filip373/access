require 'rails_helper'

describe TogglWorkers::DiffWorker do
  include_context 'data_guru'
  include_context 'toggl_api'

  before(:each) do
    allow(TogglIntegration::Api).to receive(:new).and_return(toggl_api)
    allow(DataGuru::Client).to receive(:new).and_return(data_guru)
  end

  let(:token) { 'some-random-token' }
  it { is_expected.to be_processed_in :default }

  it 'saves the status of performing diff' do
    subject.perform(token)
    expect(Rails.cache.read('toggl_performing_diff')).to eq(false)
  end

  it 'saves the diff in the cache' do
    subject.perform(token)
    expect(Rails.cache.read('toggl_calculated_diff')).not_to be_nil
    expect(Rails.cache.read('toggl_calculated_diff')).to be_a Hash
    expect(Rails.cache.read('toggl_calculated_diff')).not_to be_empty
  end

  it 'saves the errors in the cache' do
    subject.perform(token)
    expect(Rails.cache.read('toggl_calculated_errors')).not_to be_nil
    expect(Rails.cache.read('toggl_calculated_errors')).to be_a Array
    expect(Rails.cache.read('toggl_calculated_errors')).not_to be_empty
  end
end
