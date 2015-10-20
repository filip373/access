require 'rails_helper'

describe UserRepository do
  include_context 'data_guru'

  let(:users) do
    [
      OpenStruct.new(
        id: 'janusz.nowak',
        name: 'Janusz Nowak',
        emails: ['janusz.nowak@example.com'],
        github: 'gh_jnowak',
        rollbar: 'roll_jnowak',
        external: false,
      ),
      OpenStruct.new(
        id: 'marian.nowak',
        name: 'Marina Nowak',
        emails: ['marian.nowak@example.com'],
        github: 'gh_mnowak',
        rollbar: 'roll_mnowak',
        external: true,
      ),
      OpenStruct.new(
        id: 'stefan.nowak',
        name: 'Stefan Nowak',
        emails: ['stefan.nowak@example.com'],
        github: 'gh_snowak',
        rollbar: 'roll_snowak',
        external: true,
      ),
    ]
  end

  before do
    allow(DataGuru::Client).to receive(:new).and_return(data_guru)
    subject do
      described_class.new(users)
    end
  end

  describe '.find(name)' do
    it 'finds user by filename' do
      expect(subject.find(users.first.id)).to eq(users.first)
    end

    it 'raise exception if user is not in users_data' do
      expect { subject.find('nobody') }.to raise_error UserError
    end
  end

  describe '.find_by_email(email)' do
    it 'finds user outside groups' do
      expect(subject.find_by_email('marian.nowak@example.com')).to eq(users[1])
    end

    context 'user with desirable username does not exist' do
      it 'raises error' do
        expect { subject.find_by_email('not_exist@foo.pl') }.to raise_error(UserError)
      end
    end
  end

  describe '.find_many(names)' do
    context 'all users are present in users_data' do
      let(:names) { [users[0].id, users[1].id, users[2].id] }

      it 'returns hash where key is name and value is user' do
        expect(subject.find_many(names).keys).to include users[0].id
        expect(subject.find_many(names).keys).to include users[1].id
        expect(subject.find_many(names).keys).to include users[2].id
      end
    end

    context 'one of users is not present in users_data' do
      let(:names) { [users[0].id, 'marian.nowak', 'not.found'] }

      it 'find only present users' do
        expect(subject.find_many(names).keys).to include users[0].id
        expect(subject.find_many(names).keys).to include users[1].id
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
      company_users = subject.list_company_users.map
      expect(company_users).to include users[0]
      expect(company_users).to_not include users[1]
      expect(company_users).to_not include users[2]
    end
  end
end
