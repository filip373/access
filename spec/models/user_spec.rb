require 'rails_helper'

describe User do
  subject { described_class }
  let(:users_data) do
    {
      'group_one' => {
        'janusz' => { 'name' => 'Janusz Nowak', 'github' => '13art' },
        'marian' => { 'name' => 'Marian Nowak', 'github' => '76marekm' },
      },
      'group_two' => {
        'andrzej' => { 'name' => 'Andrzej Nowak', 'github' => '13art' },
      },
      'default_group' => {
        'parowka' => { 'name' => 'Parówka Nowak', 'github' => '13art' },
      },
      'michal.nowak' => { 'name' => 'Michał Nowak', 'github' => 'mnowak' },
    }
  end

  let(:company_name) { 'default_group' }

  before do
    allow(subject).to receive(:company_name) { company_name }
    allow(subject).to receive(:users_data) { users_data }
  end

  describe '.find(name)' do
    it 'finds user in default group' do
      expect(subject.find('parowka')).to be
    end

    it 'finds user nested in other group' do
      expect(subject.find('group_one/janusz')).to be
    end

    it 'finds user defined outside groups' do
      expect(subject.find('michal.nowak')).to be
    end

    it 'raise exception if user is not in users_data' do
      expect { subject.find('herbatka') }.to raise_error
    end
  end

  describe '.find_many(names)' do
    context 'all users are present in users_data' do
      let(:names) { %w(michal.nowak parowka group_one/janusz) }
      let(:expected_return) do
        {
          'michal.nowak' => { 'name' => 'Michał Nowak', 'github' => 'mnowak' },
          'parowka' => { 'name' => 'Parówka Nowak', 'github' => '13art' },
          'group_one/janusz' => { 'name' => 'Janusz Nowak', 'github' => '13art' },
        }
      end

      it 'returns array of name and gh_login of all names' do
        expect(subject.find_many(names)).to eq(expected_return)
      end
    end

    context 'one of users is not present in users_data' do
      let(:names) { %w(michal.nowak parowka herbatka) }
      let(:expected_return) do
        {
          'michal.nowak' => { 'name' => 'Michał Nowak', 'github' => 'mnowak' },
          'parowka' => { 'name' => 'Parówka Nowak', 'github' => '13art' },
        }
      end

      it 'find only present users' do
        expect(subject.find_many(names)).to eq(expected_return)
      end

      it 'add an error' do
        expect { subject.find_many(names) }.to change { subject.errors.count }.by(1)
      end

      it 'send error to rollbar' do
        allow(Rollbar).to receive(:error)
        subject.find_many(names)
        expect(Rollbar).to have_received(:error)
      end
    end
  end

  describe '.list_company_users' do
    it 'returns users only form directory company_name' do
      expect(subject.list_company_users).to be(users_data['default_group'])
    end
  end

  describe '#extenal?' do
    context 'user is from company' do
      let(:user) do
        described_class.new(
          email: "mariusz.blaszczak@#{AppConfig.google.main_domain}",
          name: 'mariusz.blaszczak',
        )
      end

      it 'returns false' do
        expect(user.external?).to be_falsy
      end
    end

    context 'user is not from company' do
      let(:user) do
        described_class.new(
          email: 'mariusz.blaszczak@wp.pl',
          name: 'mariusz.blaszczak',
        )
      end

      it 'returns true' do
        expect(user.external?).to be_truthy
      end
    end
  end

  describe '.new' do
    let(:user) do
      described_class.new(
        email: 'mariusz.blaszczak@netguru.pl',
        name: 'mariusz.blaszczak',
        full_name: 'Mariusz Blaszczak',
        github: 'Mariusz Blaszczak',
      )
    end

    it { expect(user.email).to_not be_empty }
    it { expect(user.name).to_not be_empty }
    it { expect(user.full_name).to_not be_empty }
    it { expect(user.github).to_not be_empty }

    it 'is possible to change email' do
      user.email = 'another@email.pl'
      expect(user.email).to eq 'another@email.pl'
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
        email: 'mariusz.blaszczak@netguru.pl',
        name: 'mariusz.blaszczak',
        full_name: 'Mariusz Blaszczak',
        github: 'blaszczakm',
      )
    end

    let(:yaml_object) { YAML.load user.to_yaml }

    it { expect(yaml_object.keys.count).to eq 2 }
    it { expect(yaml_object.keys.first).to eq 'name' }
    it { expect(yaml_object.keys.second).to eq 'github' }
    it { expect(yaml_object.values.first).to eq user.full_name }
    it { expect(yaml_object.values.second).to eq user.github }
  end
end
