RSpec.shared_context 'rollbar_api' do
  let(:rollbar_api) do
    double.tap do |api|
      allow(api).to receive(:list_teams) { existing_teams }
      allow(api).to receive(:list_team_members) { existing_members }
      allow(api).to receive(:list_team_projects) { existing_projects }
      allow(api).to receive(:remove_project) do |project_name, team|
        team.projects.delete_if { |r| r.name == project_name }
      end
      allow(api).to receive(:add_project) do |project_name, team|
        team.projects.push(Hashie::Mash.new name: project_name)
      end
      allow(api).to receive(:add_member) do |member_username, team|
        team.members.push(Hashie::Mash.new username: member_username)
      end
      allow(api).to receive(:remove_member) do |member_username, team|
        team.members.delete_if { |m| m.username == member_username }
      end
      allow(api).to receive(:create_team) do
        existing_teams.push(new_team)
      end.and_yield(new_team)
    end
  end

  let(:team1) do
    Hashie::Mash.new(
      name: 'team1',
      id: 1,
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
      id: 3,
      username: 'member3',
      email: 'member3@foo.pl',
    )
  end

  let(:member6) do
    Hashie::Mash.new(
      id: 6,
      username: 'member6',
      email: 'member6@foo.pl',
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

  let(:project3) do
    Hashie::Mash.new(
      id: 3,
      name: 'project3',
    )
  end

  let(:existing_teams) { [team1] }
  let(:existing_members) { [member1, member2] }
  let(:existing_projects) { [project1, project2] }
end
