require 'rails_helper'

RSpec.describe GithubIntegration::MainController do
  include_context 'gh_api'

  before(:each) do
    allow(controller).to receive(:gh_auth_required).and_return(true)
    allow(GithubIntegration::Api).to receive(:new).and_return(gh_api)
    UpdateRepo.any_instance.stub(:now!).and_return(true)
  end

  describe 'GET show_diff' do
    before { get :show_diff }

    it { expect(assigns(:gh_log)).to be_a Array }
    it { expect(controller.validation_errors).to be_a Array }
    it { expect(controller.missing_teams).to be_a Array }
    it { expect(response).to render_template('show_diff') }

    it 'run diff action once' do
      allow(GithubIntegration::Actions::Diff).to receive(:new)
      controller.get_gh_log
      expect(GithubIntegration::Actions::Diff).to_not have_received(:new)
    end

    it 'caches gh_diff value' do
      expect(Rails.cache.read('gh_diff')).to_not be_nil
      expect(Rails.cache.read('gh_diff')).to be_a Hash
      expect(Rails.cache.read('gh_diff')).to_not be_empty
    end
  end

  describe 'POST sync' do
    it 'resets cache' do
      allow(Rails.cache).to receive(:delete)
      post :sync
      expect(Rails.cache).to have_received(:delete)
    end

    it 'use cached gh_diff value' do
      controller.send(:gh_diff)
      allow(GithubIntegration::Actions::Diff).to receive(:new)
      post :sync
      allow(Rails.cache).to receive(:delete)
      expect(GithubIntegration::Actions::Diff).to_not have_received(:new)
    end

    it 'render templte sync' do
      post :sync
      expect(response).to render_template('sync')
    end
  end
end
