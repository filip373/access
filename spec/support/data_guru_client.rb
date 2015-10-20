RSpec.shared_context 'data_guru' do
  let(:users) { [] }
  let(:gh_teams) do
    [
      OpenStruct.new(
        id: 'team1',
        members: ['member1@foo.pl'],
        repos: ['repo1'],
        permission: 'push',
      ),
      OpenStruct.new(
        id: 'team2',
        members: ['member2@foo.pl'],
        repos: ['repo2'],
        permission: 'push',
      ),
    ]
  end
  let(:google_groups) { [] }
  let(:rollbar_teams) { [] }
  let(:toggl_teams) { [] }
  let(:errors) { [] }

  let(:data_guru) do
    double.tap do |dg|
      allow(dg).to receive(:users) { users }
      allow(dg).to receive(:github_teams) { gh_teams }
      allow(dg).to receive(:google_groups) { google_groups }
      allow(dg).to receive(:rollbar_teams) { rollbar_teams }
      allow(dg).to receive(:toggl_teams) { toggl_teams }
      allow(dg).to receive(:errors) { errors }
      allow(dg).to receive(:refresh) { true }
    end
  end
end
