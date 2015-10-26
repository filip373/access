RSpec.shared_context 'gh_teams' do
  include_context 'users'
  include_context 'data_guru'

  let(:team_alfa) do
    {
      id: 'team_alfa',
      members: [janusz[:id]],
      repos: %w(turbo-repo),
      permission: 'push',
    }
  end

  let(:team_new) do
    {
      id: 'team_new',
      members: [janusz[:id], stefan[:id]],
      repos: %w(hydro-repo),
      permission: 'push',
    }
  end

  let(:teams_data) do
    storage = OpenStruct.new data: {
      github_teams: {
        team_alfa[:id] => team_alfa.except(:id),
        team_new[:id] => team_new.except(:id),
      },
      config: {
        github_team: {
          permission: {
            required: true,
            default_value: 'push',
            value_type: 'string',
          },
          members: {
            required: true,
            default_value: nil,
            value_type: 'array',
          },
          repos: {
            required: true,
            default_value: nil,
            value_type: 'array',
          },
        },
      },
    }.deep_stringify_keys
    DataGuru::GithubTeamsCollection.new(storage: storage)
  end

  let(:gh_team_new) do
    GithubIntegration::Team.new(*team_new.values)
  end

  let(:expected_teams) { GithubIntegration::Team.all(data_guru.github_teams) }

  before do
    allow(DataGuru::Client).to receive(:github_teams) { teams_data }
  end
end
