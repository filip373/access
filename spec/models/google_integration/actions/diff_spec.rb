require 'rails_helper'

RSpec.describe GoogleIntegration::Actions::Diff do
  let(:expected_groups) { GoogleIntegration::Groups.all }
  let(:group1) do
    Hashie::Mash.new(
      id: 1,
      name: 'group1',
      email: 'group1@netguru.pl',
      aliases: ['alias1'],
      members: [
        Hashie::Mash.new(name: 'first.member', email: 'first.member@netguru.pl'),
        Hashie::Mash.new(id: AppConfig.google.domain_member_id),
      ],
      settings: group_settings,
    )
  end
  let(:group_settings) do
    Hashie::Mash.new(
      isArchived: 'false',
      showInGroupDirectory: 'true',
      whoCanViewGroup: 'ALL_MEMBERS_CAN_VIEW',
    )
  end
  let(:new_group) { expected_groups.find { |g| g.name == 'new_group' } }
  let(:google_api) do
    double.tap do |api|
      allow(api).to receive(:list_groups_full_info) { [group1] }
      allow(api).to receive(:errors) { {} }
    end
  end

  subject { described_class.new(expected_groups, google_api).now! }

  it { is_expected.to be_a Hash }

  context 'existing group' do
    it { expect(subject[:add_members][group1]).to eq ['second.member@netguru.pl'] }
    it { expect(subject[:remove_members][group1]).to eq ['first.member@netguru.pl'] }
    it { expect(subject[:add_aliases][group1]).to eq ['alias2'] }
    it { expect(subject[:remove_aliases][group1]).to eq ['alias1'] }
    it { expect(subject[:remove_membership][group1]).to eq(false) }
  end

  context 'new group' do
    it do
      expected_members = ['first.member@netguru.pl', 'second.member@netguru.pl']
      expect(subject[:create_groups][new_group][:add_members]).to eq(expected_members)
    end
    it { expect(subject[:create_groups][new_group][:add_aliases]).to eq %w(alias1 alias2) }
    it { expect(subject[:create_groups][new_group][:add_membership]).to eq(true) }
  end

  describe '#privacy_diff' do
    let(:privacy_open) do
      Hashie::Mash.new(
        showInGroupDirectory: 'true',
        whoCanViewGroup: 'ALL_IN_DOMAIN_CAN_VIEW',
      )
    end
    let(:privacy_closed) do
      Hashie::Mash.new(
        showInGroupDirectory: 'false',
        whoCanViewGroup: 'ALL_MEMBERS_CAN_VIEW',
      )
    end
    context 'localy is open, but on google it is closed group' do
      let(:group_settings) do
        privacy_closed
      end

      it 'overwrites changes on google' do
        expect(subject[:change_privacy][group1].open?).to be_truthy
      end
    end

    context 'localy and on google privacy is open' do
      let(:group_settings) do
        privacy_open
      end

      it 'does not list the change' do
        expect(subject[:change_privacy][group1]).to be_nil
      end
    end
  end
end
