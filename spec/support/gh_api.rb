RSpec.shared_context 'gh_api' do
  let(:gh_api) do
    double.tap do |api|
      allow(api).to receive(:list_teams) { existing_teams }
      allow(api).to receive(:teams) { existing_teams }
      allow(api).to receive(:list_team_members) do |arg|
        existing_teams[arg - 1].members
      end
      allow(api).to receive(:list_team_repos) { |arg| existing_teams[arg - 1].repos }
      allow(api).to receive(:team_member_pending?) do |team_id, user_name|
        team_id == 1 && user_name == 'thrd.mbr'
      end
      allow(api).to receive(:find_organization_id) { 1 }
    end
  end

  let(:team1) do
    Hashie::Mash.new(
      name: 'team1',
      id: 1,
      members: [login: 'first.mbr'],
      repos: [
        { name: 'first-repo', owner: { id: 1 } },
        { name: 'first-repo', owner: { id: 2 } },
      ],
      permission: 'pull',
    )
  end

  let(:team_empty) do
    Hashie::Mash.new(
      name: 'team_empty',
      id: 1,
      members: [login: 'first.mbr'],
      repos: [
        { name: 'first-repo', owner: { id: 1 } },
        { name: 'first-repo', owner: { id: 2 } },
      ],
      permission: 'pull',
    )
  end

  let(:new_team) do
    GithubIntegration::Team.new(
      'team2',
      ['first.member'],
      ['first-repo'],
      'push',
    )
  end
  let(:existing_teams) { [team1, team_empty] }
end
