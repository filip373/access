require 'rails_helper'

RSpec.describe GoogleIntegration::Actions::Diff do
  include_context 'data_guru'

  let(:expected_groups) { GoogleIntegration::Group.all(data_guru.google_groups) }
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
  let(:members) do
    [
      Hashie::Mash.new(
        name: 'first.member',
        primaryEmail: 'member1@foo.pl',
        aliases: %w(firsto elfirsto),
      ),
      Hashie::Mash.new(
        name: 'second.member',
        primaryEmail: 'member2@foo.pl',
        aliases: [],
      ),
    ]
  end
  let(:new_group) { expected_groups.find { |g| g.name == 'new_group' } }
  let(:google_api) do
    double.tap do |api|
      allow(api).to receive(:list_groups_full_info) { [group1] }
      allow(api).to receive(:errors) { {} }
      allow(api).to receive(:list_users) { members }
    end
  end
  let(:user_repo) { UserRepository.new(data_guru.members) }

  before(:each) do
    allow(DataGuru::Client).to receive(:new).and_return(data_guru)
  end

  subject { described_class.new(expected_groups, google_api, user_repo).now! }

  it { is_expected.to be_a Hash }

  context 'existing group' do
    it { expect(subject[:add_members][group1]).to eq ['member2@foo.pl'] }
    it { expect(subject[:remove_members][group1]).to eq ['first.member@netguru.pl'] }
    it { expect(subject[:add_aliases][group1]).to eq ['alias2'] }
    it { expect(subject[:remove_aliases][group1]).to eq ['alias1'] }
    it { expect(subject[:remove_membership][group1]).to eq(false) }
  end

  context 'new group' do
    it do
      expected_members = ['member1@foo.pl', 'member2@foo.pl']
      expect(subject[:create_groups][new_group][:add_members]).to eq(expected_members)
    end
    it { expect(subject[:create_groups][new_group][:add_aliases]).to eq %w(alias1 alias2) }
    it { expect(subject[:create_groups][new_group][:add_membership]).to eq(true) }
  end

  context 'user aliases' do
    it 'correctly computes aliases to add' do
      expect(subject[:add_user_aliases][data_guru.members[0]]).to eq([])
      expect(subject[:add_user_aliases][data_guru.members[1]]).to eq(['secundo'])
    end

    it 'correcly computes aliases to remove' do
      expect(subject[:remove_user_aliases][data_guru.members[0]]).to eq(['elfirsto'])
      expect(subject[:remove_user_aliases][data_guru.members[1]]).to eq([])
    end
  end

  describe '#privacy_diff' do
    let(:privacy_open) do
      Hashie::Mash.new(
        whoCanViewGroup: 'ALL_IN_DOMAIN_CAN_VIEW',
      )
    end
    let(:privacy_closed) do
      Hashie::Mash.new(
        whoCanViewGroup: 'ALL_MEMBERS_CAN_VIEW',
      )
    end

    context 'defaults are not set' do
      context 'localy is open, but on google it is a closed group' do
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
end
