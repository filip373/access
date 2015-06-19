require 'rails_helper'

RSpec.describe GoogleIntegration::MainController do
  include_context 'google_api'
  before(:each) do
    allow(controller).to receive(:google_auth_required).and_return(true)
    allow(controller).to receive(:gh_auth_required).and_return(true)
    allow(GoogleIntegration::Api).to receive(:new).and_return(google_api)
    UpdateRepo.stub(:now!).and_return(true)
  end

  describe 'GET show_diff' do
    before { get :show_diff }

    it { expect(controller.google_log).to be_a Array }
    it { expect(controller.expected_groups).to be_a Array }
    it { expect(response).to render_template('show_diff') }

    it { expect(controller.missing_accounts).to be_a Array }
    it { expect(controller.missing_accounts).to_not be_empty }

    it 'caches missing accounts' do
      controller.missing_accounts # Needs to use exposed variable since views are not rendered
      expect(Rails.cache.read('calculated_missing_accounts')).to_not be_nil
      expect(Rails.cache.read('calculated_missing_accounts')).to be_a Array
      expect(Rails.cache.read('calculated_missing_accounts')).to_not be_empty
    end
  end
end
