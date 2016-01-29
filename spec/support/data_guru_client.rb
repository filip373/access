RSpec.shared_context 'data_guru' do
  before(:each) do
    allow(DataGuru::Client).to receive(:new).and_return(data_guru)
  end

  let(:users) do
    [
      OpenStruct.new(
        id: 'first.member',
        name: 'First Member',
        github: 'first.mbr',
        rollbar: 'member1',
        emails: ['member1@foo.pl', 'first.member@mail.com'],
        aliases: ['firsto'],
      ),
      OpenStruct.new(
        id: 'second.member',
        name: 'Second Member',
        github: 'scnd.mbr',
        rollbar: 'member2',
        emails: ['member2@foo.pl', 'second.member@mail.com'],
        aliases: ['secundo'],
      ),
      OpenStruct.new(
        id: 'sixth.member',
        name: 'Sixsth Member',
        github: 'sth.mbr',
        emails: ['member6@foo.pl'],
        aliases: ['sixstho'],
      ),
      OpenStruct.new(
        id: 'third.member',
        name: 'Third Member',
        github: 'thrd.mbr',
        emails: ['member3@foo.pl', 'third.member@mail.com'],
        aliases: [],
      ),
      OpenStruct.new(
        id: 'fourth.member',
        name: 'Fourth Member',
        github: 'frth.mbr',
        emails: ['fourth.member@mail.com'],
        aliases: [],
      ),
    ]
  end

  let(:github_teams) do
    [
      OpenStruct.new(
        id: 'team1',
        members: ['second.member', 'third.member', 'fifth.member'],
        repos: ['second-repo'],
        permission: 'push',
      ),
      OpenStruct.new(
        id: 'team2',
        members: ['first.member', 'not.present'],
        repos: ['first-repo'],
        permission: 'push',
      ),
      OpenStruct.new(
        id: 'team_empty',
        members: [],
        repos: [],
        permission: 'push',
      ),
    ]
  end
  let(:google_groups) do
    [
      OpenStruct.new(
        id: 'group1',
        domain_membership: false,
        members: ['second.member'],
        aliases: ['alias2'],
        private: false,
      ),
      OpenStruct.new(
        id: 'new_group',
        domain_membership: true,
        members: ['first.member', 'second.member'],
        aliases: %w(alias1 alias2),
      ),
      OpenStruct.new(
        id: 'support_group',
        domain_membership: true,
        members: ['first.member'],
      ),
    ]
  end
  let(:rollbar_teams) { [] }
  let(:toggl_teams) { [] }
  let(:errors) { [] }
  let(:hockeyapp_apps) do
    [
      OpenStruct.new(
        name: 'App1',
        public_identifier: '1a2b3c',
        teams: %w(Team1 Team2),
        testers: ['second.member'],
        members: ['third.member'],
        developers: ['first.member'],
      ),
      OpenStruct.new(
        name: 'App2',
        public_identifier: 'abc123',
        teams: %w(Team1),
        testers: [],
        members: [],
        developers: [],
      ),
    ]
  end
  let(:jira_projects) do
    [
      ActiveStruct.new(
        name: 'AccessGuru',
        key: 'AG',
        developers: %w(dev.first dev.second),
        qas: %w(qa.first),
        pms: %w(pm.first),
        client_developers: %w(external/clientdev.first),
        clients: %w(external/client.first),
      ),
      ActiveStruct.new(
        name: 'DataGuru',
        key: 'DG',
        developers: %w(dev.first dev.second),
        qas: [],
        pms: %w(pm.second),
        client_developers: [],
        clients: %w(external/client.first),
      ),
      ActiveStruct.new(
        name: 'Permissions',
        key: 'PER',
        developers: %w(dev.first dev.second),
        qas: [],
        pms: %w(pm.second),
        client_developers: [],
        clients: %w(external/client.first),
      ),
    ]
  end

  let(:data_guru) do
    double.tap do |dg|
      allow(dg).to receive(:members) { users }
      allow_any_instance_of(Array).to receive(:all) { users }
      allow(dg).to receive(:github_teams) { github_teams }
      allow(dg).to receive(:google_groups) { google_groups }
      allow(dg).to receive(:rollbar_teams) { rollbar_teams }
      allow(dg).to receive(:toggl_teams) { toggl_teams }
      allow(dg).to receive(:hockeyapp_apps) { hockeyapp_apps }
      allow(dg).to receive(:jira_projects) { jira_projects }
      allow(dg).to receive(:errors) { errors }
      allow(dg).to receive(:refresh) { true }
    end
  end
end
