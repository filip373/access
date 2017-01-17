shared_examples 'a google_api' do
  describe '#google_authorized?' do
    before do
      controller.session[:credentials] = { admin: false }
      allow(controller).to receive(:permitted_members) { permitted_members }
    end
    let(:mock_authorization) { GoogleIntegration::Api::MockAccountAuthorization }
    let(:permitted_members) { [members.first.email] }

    subject { controller.google_authorized? }

    if Features.on?(:use_service_account)
      context 'user is authorized' do

        context 'user is s an admin' do
          before { controller.session[:credentials][:is_admin] = true }
          it { is_expected.to be_truthy }
        end

        context 'user is permitted to manage google groups' do
          before { controller.session[:credentials][:email] = members.first.email }
          it { is_expected.to be_truthy }

          context 'managers are not set' do
            it { is_expected.to be_truthy }
          end
        end

        context 'managers are not set' do
          before { controller.session[:credentials][:email] = members.second.email }
          let(:permitted_members) { [] }
          it { is_expected.to be_truthy }
        end

        context 'user is not permitted to manage google groups' do
          before { controller.session[:credentials][:email] = members.second.email }
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
