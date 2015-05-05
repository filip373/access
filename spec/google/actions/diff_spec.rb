require 'rails_helper'

RSpec.describe GoogleIntegration::Actions::Diff do
  let(:expected_groups) { GoogleIntegration::Groups.all }
  let(:group1) do
    Hashie::Mash.new(id: 1, name: 'group1', email: 'group1@netguru.pl', aliases: ['alias1'])
  end
  let(:new_group) { expected_groups.find { |g| g.name == 'new_group' } }
  let(:google_api) do
    double.tap do |api|
      api.stub(:list_groups).and_return [group1]
      api.stub(:list_members).and_return(
        [Hashie::Mash.new(name: 'first.member', email: 'first.member@netguru.pl')],
      )
    end
  end

  subject { described_class.new(expected_groups, google_api).now! }

  it { is_expected.to be_a Hash }

  context 'existing group' do
    it { expect(subject[:add_members][group1]).to eq ['second.member@netguru.pl'] }
    it { expect(subject[:remove_members][group1]).to eq ['first.member@netguru.pl'] }
    it { expect(subject[:add_aliases][group1]).to eq ['alias2'] }
    it { expect(subject[:remove_aliases][group1]).to eq ['alias1'] }
  end

  context 'new group' do
    it do
      expected_members = ['first.member@netguru.pl', 'second.member@netguru.pl']
      expect(subject[:create_groups][new_group][:add_members]).to eq(expected_members)
    end
    it { expect(subject[:create_groups][new_group][:add_aliases]).to eq %w(alias1 alias2) }
  end
end
