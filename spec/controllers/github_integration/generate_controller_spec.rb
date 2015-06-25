require 'rails_helper'

module GithubIntegration
  describe GenerateController do
    include_context 'gh_api'

    before(:each) do
      allow(controller).to receive(:gh_auth_required) { true }
      allow(GithubIntegration::Api).to receive(:new).and_return(gh_api)
    end

    describe '#permissions' do
      let(:permissions_dir) { Rails.root.join('tmp/test_permissions') }

      describe 'creating github teams' do
        before do
          allow(controller).to receive(:permissions_dir).and_return(permissions_dir)
          get :permissions
        end

        after { FileUtils.rm_rf(permissions_dir) }

        subject { YAML.load_file(permissions_dir.join('github_teams/team1.yml')) }

        it 'creates a github team' do
          expect(File.exist?(permissions_dir.join('github_teams/team1.yml'))).to be_truthy
          expect(subject).not_to be_falsy
        end

        describe 'contents of yaml file' do
          it { expect(subject['permission']).to eq 'pull' }
          it { expect(subject['members']).to match %w(first.mbr) }
          it { expect(subject['repos']).to match %w(first-repo) }
        end
      end
    end
  end
end
