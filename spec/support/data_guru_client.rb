RSpec.shared_context 'data_guru' do
  let(:users) do
    [
      OpenStruct.new(
        id: 'first.member',
        name: 'First Member',
        github: 'first.mbr',
        rollbar: 'member1',
        emails: ['member1@foo.pl'],
        aliases: ['firsto'],
      ),
      OpenStruct.new(
        id: 'second.member',
        name: 'Second Member',
        github: 'scnd.mbr',
        rollbar: 'member2',
        emails: ['member2@foo.pl'],
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
        emails: ['member3@foo.pl'],
        aliases: [],
      ),
    ]
  end

  let(:github_teams) do
    [
      OpenStruct.new(
        id: 'team1',
        members: ['second.member', 'third.member', 'fourth.member'],
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

  let(:data_guru) do
    double.tap do |dg|
      allow(dg).to receive(:users) { users }
      allow_any_instance_of(Array).to receive(:all) { users }
      allow(dg).to receive(:github_teams) { github_teams }
      allow(dg).to receive(:google_groups) { google_groups }
      allow(dg).to receive(:rollbar_teams) { rollbar_teams }
      allow(dg).to receive(:toggl_teams) { toggl_teams }
      allow(dg).to receive(:errors) { errors }
      allow(dg).to receive(:refresh) { true }
    end
  end
end
