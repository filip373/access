require 'rails_helper'

RSpec.describe GoogleIntegration::Actions::Log do
  let(:group) { Hashie::Mash.new name: 'group1', email: 'group1', fake: true }
  let(:new_group) { Hashie::Mash.new name: 'new_group', email: 'new_group', fake: true }
  let(:diff) do
    {
      create_groups: {
        new_group => {
          add_members: ['first.member'],
          add_aliases: ['alias1'],
          add_membership: true,
        },
      },
      add_members: {
        group => ['second.member'],
      },
      remove_members: {
        group => ['first.member'],
      },
      add_aliases: {
        group => ['alias2'],
      },
      remove_aliases: {
        group => ['alias1'],
      },
      remove_membership: {
        group => nil,
      },
      change_archive: {
        group => false,
      },
      change_privacy: {
        group => ::GoogleIntegration::GroupPrivacy.new(Hashie::Mash.new).close!,
      },
    }
  end

  let(:empty_diff) do
    {
      create_groups: {},
      add_members: {},
      remove_members: {},
      add_aliases: {},
      remove_aliases: {},
      add_membership: {},
      remove_membership: {},
      change_archive: {},
      change_privacy: {},
    }
  end

  subject { described_class.new(diff).now! }
  it { is_expected.to be_a Array }

  # rubocop:disable Metrics/LineLength
  context 'with changes' do
    it { is_expected.to satisfy { |log| log.size == 11 } }
    it { is_expected.to include "[api] create group #{new_group.name}" }
    it { is_expected.to include "[api] add member #{diff[:create_groups][new_group][:add_members][0]} to group #{new_group.name}" }
    it { is_expected.to include "[api] add alias #{diff[:create_groups][new_group][:add_aliases][0]} to group #{new_group.name}" }
    it { is_expected.to include "[api] add domain membership to group #{new_group.email}" }
    it { is_expected.to include "[api] add member #{diff[:add_members][group][0]} to group #{group.name}" }
    it { is_expected.to include "[api] remove member #{diff[:remove_members][group][0]} from group #{group.name}" }
    it { is_expected.to include "[api] add alias #{diff[:add_aliases][group][0]} to group #{group.name}" }
    it { is_expected.to include "[api] remove alias #{diff[:remove_aliases][group][0]} from group #{group.name}" }
    it { is_expected.to include "[api] change group #{group.email} archive settings to false" }
    it { is_expected.to include "[api] change group #{group.email} privacy settings to closed" }
    it { is_expected.to include "[api] remove domain membership from group #{group.email}" }
  end
  # rubocop:enable Metrics/LineLength

  context 'without changes' do
    subject { described_class.new(empty_diff).now! }

    it { is_expected.to satisfy { |log| log.size == 1 } }
    it { is_expected.to include 'There are no changes.' }
  end
end
