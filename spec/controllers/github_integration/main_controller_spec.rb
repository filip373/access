require 'rails_helper'

RSpec.describe GithubIntegration::MainController do
  include_context 'gh_api'
  include_context 'data_guru'

  before(:each) do
    allow(controller).to receive(:gh_auth_required).and_return(true)
    allow(GithubIntegration::Api).to receive(:new).and_return(gh_api)
    allow(DataGuru::Client).to receive(:new).and_return(data_guru)
  end

  describe 'GET calculate_diff' do
    context 'without cache' do
      it 'renders calculating diff page' do
        Rails.cache.delete('github_performing_diff')
        get :calculate_diff
        expect(response).to render_template('calculate_diff')
      end
    end

    context 'with cache' do
      before do
        Rails.cache.fetch('github_performing_diff') do
          false
        end
        get :calculate_diff
      end

      it { expect(response).to redirect_to(:github_show_diff) }
    end
  end

  describe 'GET refresh_cache' do
    before do
      Rails.cache.write('github_calculated_diff', {})
      Rails.cache.write('github_calculated_errors', [])
      Rails.cache.write('github_performing_diff', false)
    end

    it 'clear cache' do
      get :refresh_cache
      expect(Rails.cache.read('github_calculated_diff')).to be_nil
      expect(Rails.cache.read('github_calculated_errors')).to be_nil
      expect(Rails.cache.read('github_performing_diff')).to be_nil
    end

    it 'redirects to calculating diff page' do
      get :refresh_cache
      expect(response).to redirect_to(:github_calculate_diff)
    end
  end

  describe 'GET show_diff' do
    before { get :show_diff }

    it { expect(response).to render_template('show_diff') }
  end

  describe 'POST sync' do
    before do
      allow_any_instance_of(GithubIntegration::SyncJob).to receive(:perform)
    end

    it 'resets cache' do
      allow(Rails.cache).to receive(:delete)
      post :sync
      expect(Rails.cache).to have_received(:delete).with('github_calculated_diff')
      expect(Rails.cache).to have_received(:delete).with('github_calculated_errors')
      expect(Rails.cache).to have_received(:delete).with('github_performing_diff')
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
      expect { subject }.to_not raise_error
    end

    it 'redirects to cleanup_complete path' do
      subject
      expect( response ).to redirect_to(:github_cleanup_complete)
    end
  end

  describe 'DELETE cleanup_members' do
    before do
      allow(controller).to receive(:teamless_users)
        .and_return({teamless: [], missing_from_dg: []})
    end

    subject { delete :cleanup_members }
    it 'initialize CleanupMembers class' do
      allow_any_instance_of(GithubIntegration::Actions::CleanupMembers).to receive(:now!)
      subject
      expect(controller.members_cleanup).to have_received(:now!)
    end

    it 'redirects to cleanup_complete path' do
      subject
      expect(response).to redirect_to(:github_cleanup_complete)
    end
  end
end
