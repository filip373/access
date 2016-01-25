RSpec.shared_context 'hockeyapp_api' do
  let(:hockeyapp_api) do
    double.tap do |api|
      allow(api).to receive(:list_apps) { existing_apps }
      allow(api).to receive(:list_app_users) do |app_id|
        case app_id
        when '1a2b3c'
          app1_users
        when 'd3s2a1'
          app3_users
        end
      end
      allow(api).to receive(:list_app_teams) do |app_id|
        case app_id
        when '1a2b3c'
          app1_teams
        when 'd3s2a1'
          app3_teams
        end
      end
    end
  end

  let(:existing_apps) do
    {
      'apps': [app1, app3],
    }.stringify_keys
  end

  let(:app1) do
    {
      title: 'App1',
      public_identifier: '1a2b3c',
      id: 1,
      platform: 'iOS',
      custom_release_type: 'staging',
    }.stringify_keys
  end

  let(:app3) do
    {
      title: 'App3',
      public_identifier: 'd3s2a1',
      id: 3,
      platform: 'Android',
      custom_release_type: 'production',
    }.stringify_keys
  end

  let(:app1_users) do
    {
      'app_users': [
        {
          'email': 'first.member@mail.com',
          'role': 1,
        }.stringify_keys,
        {
          'email': 'second.member@mail.com',
          'role': 3,
        }.stringify_keys,
        {
          'email': 'fourth.member@mail.com',
          'role': 2,
        }.stringify_keys,
      ],
    }.stringify_keys
  end

  let(:app1_teams) do
    {
      'teams': [
        {
          id: 1,
          name: 'Team1',
        }.stringify_keys,
        {
          id: 4,
          name: 'Team4',
        }.stringify_keys,
      ],
    }.stringify_keys
  end

  let(:app3_users) do
    {
      'app_users': [],
    }.stringify_keys
  end

  let(:app3_teams) do
    {
      'teams': [],
    }.stringify_keys
  end
end
