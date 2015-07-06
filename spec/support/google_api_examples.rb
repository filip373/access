shared_examples 'a google_api' do
  describe '#google_authorized?' do
    before { allow(controller.google_api).to receive(:user_info) { user } }
    let(:mock_authorization) { GoogleIntegration::Api::MockAccountAuthorization }

    subject { controller.google_authorized?(authorization: mock_authorization) }

    if AppConfig.features.use_service_account?
      context 'user is authorized' do
        before { session[:credentials] = { some: :valid_credentials } }

        context 'user is permitted to manage google groups' do
          before { allow(controller).to receive(:permitted_members) { [members.first.email] } }

          let(:user) { members.first }
          it { is_expected.to be_truthy }

          context 'managers are not set' do
            before { allow(controller).to receive(:permitted_members) { [] } }
            it { is_expected.to be_truthy }
          end
        end

        context 'managers are not set' do
          let(:user) { members[1] }
          before { allow(controller).to receive(:permitted_members) { [] } }
          it { is_expected.to be_truthy }
        end

        context 'user is not permitted to manage google groups' do
          before { allow(controller).to receive(:permitted_members) { [members.first.email] } }

          let(:user) { members[1] }
          it { is_expected.to be_falsy }
        end
      end

      context 'user is not logged in to google account' do
        before { session[:credentials] = nil }

        it { is_expected.to be_falsy }

        context 'managers are not set' do
          before { allow(controller).to receive(:permitted_members) { [] } }

          it { is_expected.to be_falsey }
        end
      end
    else
      it { is_expected.to be_truthy }
    end
  end
end
