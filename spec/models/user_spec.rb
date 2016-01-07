require 'rails_helper'

describe User do
  subject { described_class }

  describe '.new' do
    let(:user) do
      described_class.new(
        emails: ['mariusz.blaszczak@netguru.pl'],
        external: false,
        name: 'mariusz.blaszczak',
        full_name: 'Mariusz Blaszczak',
        github: 'Mariusz Blaszczak',
      )
    end

    it { expect(user.emails).to_not be_empty }
    it { expect(user.name).to_not be_empty }
    it { expect(user.full_name).to_not be_empty }
    it { expect(user.github).to_not be_empty }
    it { expect(user.external).to_not eq nil }

    it 'is possible to change email' do
      user.emails = 'another@email.pl'
      expect(user.emails).to include 'another@email.pl'
    end

    it 'is possible to change name' do
      user.name = 'another.name'
      expect(user.name).to eq 'another.name'
    end

    it 'is possible to change full_name' do
      user.full_name = 'Another Fullname'
      expect(user.full_name).to eq 'Another Fullname'
    end

    it 'is possible to change github' do
      user.github = 'oterlogin'
      expect(user.github).to eq 'oterlogin'
    end
  end

  describe '#to_yaml' do
    let(:user) do
      described_class.new(
        emails: ['mariusz.blaszczak@netguru.pl'],
        external: false,
        name: 'mariusz.blaszczak',
        full_name: 'Mariusz Blaszczak',
        github: 'blaszczakm',
        aliases: [],
      )
    end

    let(:yaml_object) { YAML.load user.to_yaml }

    it { expect(yaml_object.keys.count).to eq 5 }
    it { expect(yaml_object.keys.first).to eq 'name' }
    it { expect(yaml_object.keys.second).to eq 'github' }
    it { expect(yaml_object.keys.third).to eq 'external' }
    it { expect(yaml_object.keys.fourth).to eq 'emails' }
    it { expect(yaml_object.keys.fifth).to eq 'aliases' }
    it { expect(yaml_object.values.first).to eq user.full_name }
    it { expect(yaml_object.values.second).to eq user.github }
    it { expect(yaml_object.values.third).to eq user.external }
    it { expect(yaml_object.values.fourth).to eq user.emails }
    it { expect(yaml_object.values.fifth).to eq user.aliases }
  end
end
