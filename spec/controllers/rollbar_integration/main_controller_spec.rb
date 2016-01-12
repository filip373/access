require 'rails_helper'

RSpec.describe RollbarIntegration::MainController do
  include_context 'rollbar_api'
  include_context 'data_guru'

  before(:each) do
    allow(controller).to receive(:gh_auth_required).and_return(true)
    allow(RollbarIntegration::Api).to receive(:new).and_return(rollbar_api)
    allow(DataGuru::Client).to receive(:new).and_return(data_guru)
  end

  describe 'GET calculate_diff' do
    context 'without cache' do
      it 'renders calculating diff page' do
        Rails.cache.delete('rollbar_performing_teams')
        get :calculate_diff
        expect(response).to render_template('calculate_diff')
      end
    end

    context 'with cache' do
      before do
        Rails.cache.write('rollbar_performing_teams', false)
        get :calculate_diff
      end

      it { expect(response).to redirect_to(:rollbar_show_diff) }
    end
  end

  describe 'GET refresh_cache' do
    before do
      Rails.cache.write('rollbar_calculated_teams', [])
      Rails.cache.write('rollbar_performing_teams', false)
    end

    it 'clears the cache' do
      get :refresh_cache
      expect(Rails.cache.read('rollbar_calculated_teams')).to be_nil
      expect(Rails.cache.read('rollbar_performing_teams')).to be_nil
    end

    it 'redirects to calculate page' do
      get :refresh_cache
      expect(response).to redirect_to(:rollbar_calculate_diff)
    end
  end
end
