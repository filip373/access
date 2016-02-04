RSpec.shared_context 'rollbar_api' do
  let(:expected_teams) do
    [
      RollbarIntegration::Team.new('new_team',
                                   ['third.member'],
                                   ['project2']),
      RollbarIntegration::Team.new('team1',
                                   ['first.member', 'second.member', 'forth.member'],
                                   %w(project1 project2)),
      RollbarIntegration::Team.new('team2',
                                   ['third.member'],
                                   ['project2']),
      RollbarIntegration::Team.new('team_empty',
                                   [],
                                   []),
    ]
  end
  let(:rollbar_api) do
    double.tap do |api|
      allow(api).to receive(:list_teams) { existing_teams }
      allow(api).to receive(:list_team_members) { existing_members }
      allow(api).to receive(:list_team_pending_members) { [] }
      allow(api).to receive(:list_all_team_members) do
        rollbar_api.list_team_members + rollbar_api.list_team_pending_members
      end
      allow(api).to receive(:list_team_projects) { existing_projects }
      allow(api).to receive(:remove_project_from_team) do |project_id, _team_id|
        project = all_projects.find { |p| p.id == project_id }
        team.projects.delete(project.name)
      end
      allow(api).to receive(:add_project_to_team) do |project_id, team_id|
        project = all_projects.find { |p| p.id == project_id }
        if team_id == 1
          team.projects[project.name] = project
        else
          new_team.projects[project.name] = project
        end
      end
      allow(api).to receive(:invite_member_to_team) do |member_email, team_id|
        member = all_members.find { |m| m.email == member_email }
        if team_id == 1
          team.members[member_email] = member
        else
          new_team.members[member_email] = member
        end
      end
      allow(api).to receive(:remove_member_from_team) do |member_id, _team_id|
        member = all_members.find { |m| m.id == member_id }
        team.members.delete(member.emails.first)
      end
      allow(api).to receive(:create_team) do
        existing_teams.push(new_team)
      end.and_return(created_new_team)
      allow(api).to receive(:list_account_projects) { all_projects }
    end
  end

  let(:created_new_team) do
    new_team.id = 2
    new_team
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
    )
  end

  let(:new_team) do
    Hashie::Mash.new name: 'new team'
  end

  let(:member1) do
    Hashie::Mash.new(
      id: 1,
      username: 'member1',
      email: 'member1@foo.pl',
      emails: ['member1@foo.pl'],
    )
  end

  let(:member2) do
    Hashie::Mash.new(
      id: 2,
      username: 'member2',
      email: 'member2@foo.pl',
      emails: ['member2@foo.pl'],
    )
  end

  let(:member3) do
    Hashie::Mash.new(
      id: 3,
      username: 'member3',
      email: 'member3@foo.pl',
      emails: ['member3@foo.pl'],
    )
  end

  let(:member5) do
    Hashie::Mash.new(
      id: 5,
      username: 'member5',
      email: 'member5@foo.pl',
      emails: ['member5@foo.pl'],
    )
  end

  let(:member6) do
    Hashie::Mash.new(
      id: 6,
      username: 'member6',
      email: 'member6@foo.pl',
      emails: ['member6@foo.pl'],
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
  let(:all_projects) { [project1, project2, project3] }
  let(:all_members) { [member1, member2, member3, member6] }
end
