shared_examples 'a google_api' do
  describe '#google_authorized?' do
    before do
      allow(controller.google_api).to receive(:user_email) { user.email }
      allow(controller.google_api).to receive(:admin?) { admin? }
      allow(controller).to receive(:permitted_members) { permitted_members }
    end
    let(:mock_authorization) { GoogleIntegration::Api::MockAccountAuthorization }
    let(:admin?) { false }
    let(:permitted_members) { [members.first.email] }

    subject { controller.google_authorized? }

    if Features.on?(:use_service_account)
      context 'user is authorized' do
        before { session[:credentials] = { some: :valid_credentials } }

        context 'user is s an admin' do
          let(:admin?) { true }
          it { is_expected.to be_truthy }
        end

        context 'user is permitted to manage google groups' do
          let(:user) { members.first }
          it { is_expected.to be_truthy }

          context 'managers are not set' do
            it { is_expected.to be_truthy }
          end
        end

        context 'managers are not set' do
          let(:user) { members.second }
          let(:permitted_members) { [] }
          it { is_expected.to be_truthy }
        end

        context 'user is not permitted to manage google groups' do
          let(:user) { members.second }
          it { is_expected.to be_falsy }
        end
      end

      context 'user is not logged in to google account' do
        before { session[:credentials] = nil }

        it { is_expected.to be_falsy }

        context 'managers are not set' do
          let(:permitted_members) { [] }

          it { is_expected.to be_falsey }
        end
      end
    else
      it { is_expected.to be_truthy }
    end
  end
end
