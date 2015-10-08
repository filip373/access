require 'rails_helper'

RSpec.describe GoogleIntegration::MainController do
  include_context 'google_api'
  it_behaves_like 'a google_api'

  before(:each) do
    allow(controller).to receive(:google_auth_required).and_return(true)
    allow(controller).to receive(:gh_auth_required).and_return(true)
    allow(GoogleIntegration::Api).to receive(:new).and_return(google_api)
    allow(DataGuru::Client).to receive(:new).and_return(DataGuru::Client.new)
    allow(DataGuru::Client.new).to receive(:refresh).and_return(true)
  end

  context 'is permitted to manage google groups' do
    before do
      if Features.on?(:use_service_account)
        allow(controller).to receive(:google_authorized?).and_return(true)
      end
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
        expect(Rails.cache.read('google_calculated_missing_accounts')).to_not be_nil
        expect(Rails.cache.read('google_calculated_missing_accounts')).to be_a Array
        expect(Rails.cache.read('google_calculated_missing_accounts')).to_not be_empty
      end

      it 'caches google_diff value' do
        controller.google_log # Needs to use exposed variable since views are not rendered
        expect(Rails.cache.read('google_calculated_diff')).to_not be_nil
        expect(Rails.cache.read('google_calculated_diff')).to be_a Hash
        expect(Rails.cache.read('google_calculated_diff')).to_not be_empty
      end
    end

    describe 'POST create_accounts' do
      before do
        allow_any_instance_of(GoogleIntegration::Actions::CreateAccounts).to receive(:now!) do
          {
            'second.member' => { email: 'second.member@netguru.pl', codes: %w(a b c) },
            'third.member' => { email: 'third.member@netguru.pl', codes: %w(a b c) },
          }
        end
        Rails.cache.fetch('calculated_missing_accounts') { 'calculated_missing_accounts' }
        ActionMailer::Base.deliveries = []
        post :create_accounts
      end

      it 'sends emails to office' do
        expect(ActionMailer::Base.deliveries.count).to eq(2)
      end

      it 'resets cache' do
        expect(Rails.cache.read('google_calculated_missing_accounts')).to be_nil
      end
    end
  end
end
