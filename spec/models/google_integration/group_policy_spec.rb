require 'rails_helper'

module GoogleIntegration
  describe GroupPolicy do
    include_context 'google_api'

    describe '#edit?' do
      subject { described_class.edit?(group_identifier) }

      context 'user can edit the group' do
        context 'group is identified by email' do
          let(:group_identifier) { 'group1@netguru.pl' }
          it { is_expected.to be_truthy }
        end
      end

      context "user can't edit the group" do
        context 'group is identified by email' do
          let(:group_identifier) { 'new_group@netguru.pl' }
          it { is_expected.to be_falsey }
        end
      end
    end
  end
end
