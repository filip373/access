RSpec.shared_context 'google_api' do
  let(:group1) do
    Hashie::Mash.new(
      id: 1,
      name: 'group1',
      email: 'group1@netguru.pl',
      aliases: ['alias1'],
      members: [members[0], members[1]],
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
      allow(api).to receive(:list_users) { members }
      allow(api).to receive(:create_user) do |params|
        params
      end
      allow(api).to receive(:post_filters)
      allow(api).to receive(:get_codes) { %w(a b c) }
      allow(api).to receive(:reset_password)
      allow(api).to receive(:generate_codes)
      allow(api).to receive(:errors) { {} }
    end
  end

  let(:members) do
    [
      Hashie::Mash.new(
        name: 'first.member',
        email: 'first.member@netguru.pl',
        primaryEmail: 'first.member@netguru.pl',
      ),
      Hashie::Mash.new(id: AppConfig.google.domain_member_id),
    ]
  end
end
