RSpec.shared_context 'rollbar_api' do
  let(:rollbar_api) do
    double.tap do |api|
      allow(api).to receive(:list_teams) { existing_teams }
      allow(api).to receive(:list_team_members) { existing_members }
      allow(api).to receive(:list_team_projects) { existing_projects }
    end
  end

  let(:team1) do
    Hashie::Mash.new(
      name: 'team1',
      id: 1,
      account_id: 1,
    )
  end

  let(:team2) do
    Hashie::Mash.new(
      name: 'team2',
      id: 2,
      account_id: 1,
    )
  end

  let(:member1) do
    Hashie::Mash.new(
      id: 1,
      username: 'member1',
      email: 'member1@foo.pl',
    )
  end

  let(:member2) do
    Hashie::Mash.new(
      id: 2,
      username: 'member2',
      email: 'member2@foo.pl',
    )
  end

  let(:member3) do
    Hashie::Mash.new(
      id: 2,
      username: 'member3',
      email: 'member3@foo.pl',
    )
  end

  let(:project1) do
    Hashie::Mash.new(
      id: 1,
      name: 'project1',
    )
  end

  let(:project2) do
    Hashie::Mash.new(
      id: 2,
      name: 'project2',
    )
  end

  let(:existing_teams) { [team1, team2] }
  let(:existing_members) { [member1, member2, member3] }
  let(:existing_projects) { [project1, project2] }
end
