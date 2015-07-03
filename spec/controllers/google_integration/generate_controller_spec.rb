require 'rails_helper'

module GoogleIntegration
  describe GenerateController do
    include_context 'gh_api'
    include_context 'google_api'
    it_behaves_like 'a google_api'

    before(:each) do
      allow(controller).to receive(:google_auth_required) { true }
      allow(controller).to receive(:gh_auth_required) { true }
      if AppConfig.features.use_service_account?
        allow(controller).to receive(:unauthorized_access).and_return(true)
      end
      allow(google_api).to receive(:list_groups_full_info) { groups }
      allow(GoogleIntegration::Api).to receive(:new).and_return(google_api)
    end

    describe '#permissions' do
      let(:permissions_dir) { Rails.root.join('tmp/test_permissions') }

      describe 'creating google groups' do
        before do
          google_api = double
          allow(google_api).to receive(:list_groups_full_info).and_return(groups)
          allow(controller).to receive(:google_api).and_return(google_api)
          allow(controller).to receive(:permissions_dir).and_return(permissions_dir)
          get :permissions
        end

        after { FileUtils.rm_rf(permissions_dir) }

        let(:groups) do
          JSON.load(Rails.root.join('spec/fixtures/google/team_example.json')).map do |group|
            Hashie::Mash.new group
          end
        end

        subject { YAML.load_file(permissions_dir.join('google_groups/team.yml')) }

        it 'creates a google group' do
          expect(File.exist?(permissions_dir.join('google_groups/team.yml'))).to be_truthy
          expect(subject).not_to be_falsy
        end

        describe 'contents of yaml file' do
          let(:group) { groups.first }
          it { expect(subject['members']).to match ['jon.hanks', 'beth.hamilthon'] }
          it { expect(subject['aliases']).to eq [] }
          it { expect(subject['domain_membership']).to eq false }
          it { expect(subject['privacy']).to eq 'open' }
          it { expect(subject['archive']).to eq true }
        end
      end
    end
  end
end
