require 'rails_helper'

RSpec.describe GithubIntegration::MainController do
  include_context 'gh_api'

  before(:each) do
    allow(controller).to receive(:gh_auth_required).and_return(true)
    allow(GithubIntegration::Api).to receive(:new).and_return(gh_api)
    UpdateRepo.stub(:now!).and_return(true)
  end

  describe 'GET show_diff' do
    before { get :show_diff }

    it { expect(controller.gh_log).to be_a Array }
    it { expect(controller.validation_errors).to be_a Array }
    it { expect(controller.missing_teams).to be_a Array }
    it { expect(response).to render_template('show_diff') }

    it 'run diff action once' do
      allow(GithubIntegration::Actions::Diff).to receive(:new)
      controller.send(:calculated_diff)
      expect(GithubIntegration::Actions::Diff).to_not have_received(:new)
    end

    it 'caches gh_diff value' do
      expect(Rails.cache.read('calculated_diff')).to_not be_nil
      expect(Rails.cache.read('calculated_diff')).to be_a Hash
      expect(Rails.cache.read('calculated_diff')).to_not be_empty
    end

    it 'terminates diff actor' do
      diff = assigns(:diff)
      expect(diff.alive?).to_not eq(true)
    end
  end

  describe 'POST sync' do
    before do
      allow_any_instance_of(GithubIntegration::SyncJob).to receive(:perform)
    end

    it 'resets cache' do
      allow(Rails.cache).to receive(:delete)
      post :sync
      expect(Rails.cache).to have_received(:delete)
    end

    it 'use cached gh_diff value' do
      controller.send(:calculated_diff)
      allow(GithubIntegration::Actions::Diff).to receive(:new)
      post :sync
      expect(GithubIntegration::Actions::Diff).to_not have_received(:new)
    end

    it 'render templte sync' do
      post :sync
      expect(response).to render_template('sync')
    end
  end

  describe 'DELETE cleanup_teams' do
    subject { delete :cleanup_teams }
    it 'initialize CleanupTeams class' do
      allow_any_instance_of(GithubIntegration::Actions::CleanupTeams).to receive(:now!)
      subject
      expect(controller.teams_cleanup).to have_received(:now!)
    end

    it 'does not raise any errors' do
      expect{ subject }.to_not raise_error
    end
  end
end
