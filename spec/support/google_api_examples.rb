shared_examples 'a google_api' do
  describe '#google_authorized?' do
    let(:mock_authorization) { GoogleIntegration::Api::MockAccountAuthorization }

    before do
      allow_any_instance_of(mock_authorization).to receive(:email) { user.email }
    end

    subject { controller.google_authorized?(authorization: mock_authorization) }

    if AppConfig.features.use_service_account?
      context 'user is authorized' do
        before { session[:credentials] = { some: :valid_credentials } }

        context 'user is permitted to manage google groups' do
          let(:user) { members.first }
          it { is_expected.to be_truthy }

          context 'managers are not set' do
            before { allow(controller).to receive(:permitted_members) { [] } }
            it { is_expected.to be_truthy }
          end
        end

        context 'managers are not set' do
          let(:user) { members.last }
          before { allow(controller).to receive(:permitted_members) { [] } }
          it { is_expected.to be_truthy }
        end

        context 'user is not permitted to manage google groups' do
          let(:user) { members.last }
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
