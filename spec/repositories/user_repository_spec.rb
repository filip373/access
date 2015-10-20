require 'rails_helper'

describe UserRepository do
  include_context 'data_guru'

  let(:janusz) do
    {
      id: 'janusz.nowak',
      name: 'Janusz Nowak',
      emails: ['janusz.nowak@example.com'],
      github: 'gh_jnowak',
      rollbar: 'roll_jnowak',
      external: false,
    }
  end
  let(:marian) do
    {
      id: 'marian.nowak',
      name: 'Marina Nowak',
      emails: ['marian.nowak@example.com'],
      github: 'gh_mnowak',
      rollbar: 'roll_mnowak',
      external: true,
    }
  end
  let(:stefan) do
    {
      id: 'stefan.nowak',
      name: 'Stefan Nowak',
      emails: ['stefan.nowak@example.com'],
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
          emails: {
            required: true,
            default_value: nil,
            value_type: 'array',
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
          },
        },
      },
    }.deep_stringify_keys
    DataGuru::UsersCollection.new(storage: storage)
  end

  before do
    allow(DataGuru::Client).to receive(:new).and_return(data_guru)
    subject do
      described_class.new(users_data)
    end
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

      it 'returns hash where key is name and value is user' do
        expect(subject.find_many(names).keys).to include janusz[:id]
        expect(subject.find_many(names).keys).to include marian[:id]
        expect(subject.find_many(names).keys).to include stefan[:id]
      end
    end

    context 'one of users is not present in users_data' do
      let(:names) { [janusz[:id], marian[:id], 'not.found'] }

      it 'find only present users' do
        expect(subject.find_many(names).keys).to include janusz[:id]
        expect(subject.find_many(names).keys).to include marian[:id]
        expect(subject.find_many(names).keys).to_not include 'not.found'
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
end
