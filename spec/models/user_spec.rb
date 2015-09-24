require 'rails_helper'

describe User do
  subject { described_class }
  let(:janusz) do
    {
      id: 'janusz.nowak',
      name: 'Janusz Nowak',
      email: 'janusz.nowak@example.com',
      github: 'gh_jnowak',
      rollbar: 'roll_jnowak',
      external: false,
    }
  end
  let(:marian) do
    {
      id: 'marian.nowak',
      name: 'Marina Nowak',
      email: 'marian.nowak@example.com',
      github: 'gh_mnowak',
      rollbar: 'roll_mnowak',
      external: true,
    }
  end
  let(:stefan) do
    {
      id: 'stefan.nowak',
      name: 'Stefan Nowak',
      email: 'stefan.nowak@example.com',
      github: 'gh_snowak',
      rollbar: 'roll_snowak',
      external: true,
    }
  end

  let(:users_data) do
    storage = OpenStruct.new data: {
      users: {
        janusz[:id] => janusz.except(:id),
        marian[:id] => marian.except(:id),
        stefan[:id] => stefan.except(:id),
      },
      config: {
        user: {
          name: {
            required: true,
            default_value: nil,
            value_type: 'string',
          },
          email: {
            required: true,
            default_value: nil,
            value_type: 'string',
          },
          github: {
            required: true,
            default_value: nil,
            value_type: 'string',
          },
          rollbar: {
            required: false,
            default_value: false,
            value_type: 'string',
          },
          external: {
            required: true,
            default_value: false,
            value_type: 'boolean',
          }
        }
      }
    }.deep_stringify_keys
    DataGuru::UsersCollection.new(storage: storage)
  end

  before do
    allow(subject).to receive(:users_data) { users_data }
  end

  describe '.find(name)' do
    it 'finds user by filename' do
      expect(subject.find(janusz[:id])).to have_attributes(janusz)
    end

    it 'raise exception if user is not in users_data' do
      expect { subject.find('nobody') }.to raise_error UserError
    end
  end

  describe '.find_by_rollbar(username)' do
    it 'finds user by rollbar username' do
      expect(subject.find_by_rollbar('roll_mnowak')).to have_attributes(marian)
    end

    context 'user with desirable username does not exist' do
      it 'raises error' do
        expect { subject.find_by_rollbar('not_exist') }.to raise_error(UserError)
      end
    end
  end

  describe '.find_by_email(email)' do
    it 'finds user outside groups' do
      expect(subject.find_by_email('marian.nowak@example.com')).to have_attributes(marian)
    end

    context 'user with desirable username does not exist' do
      it 'raises error' do
        expect { subject.find_by_email('not_exist@foo.pl') }.to raise_error(UserError)
      end
    end
  end

  describe '.find_many(names)' do
    context 'all users are present in users_data' do
      let(:names) { [janusz[:id], marian[:id], stefan[:id]] }

      it 'returns array of name and gh_login of all names' do
        expect(subject.find_many(names)).to include janusz[:id] => janusz[:github]
        expect(subject.find_many(names)).to include marian[:id] => marian[:github]
        expect(subject.find_many(names)).to include stefan[:id] => stefan[:github]
      end
    end

    context 'one of users is not present in users_data' do
      let(:names) { [janusz[:id], marian[:id], 'not.found'] }

      it 'find only present users' do
        expect(subject.find_many(names)).to include [janusz[:id], janusz[:github]]
        expect(subject.find_many(names)).to include [marian[:id], marian[:github]]
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
    # this will pass when DataGuru::ModelBase#attributes includes :id
    it 'returns users only form directory company_name' do
      company_users = subject.list_company_users.map(&:attributes)
      expect(company_users).to include janusz
      expect(company_users).to_not include marian
      expect(company_users).to_not include stefan
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

    it { expect(yaml_object.keys.count).to eq 3 }
    it { expect(yaml_object.keys.first).to eq 'name' }
    it { expect(yaml_object.keys.second).to eq 'github' }
    it { expect(yaml_object.keys.third).to eq 'email' }
    it { expect(yaml_object.values.first).to eq user.full_name }
    it { expect(yaml_object.values.second).to eq user.github }
    it { expect(yaml_object.values.third).to eq user.email }
  end
end
