RSpec.shared_context 'users' do
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
    allow(User).to receive(:users_data) { users_data }
  end
end
