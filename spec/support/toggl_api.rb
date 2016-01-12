RSpec.shared_context 'toggl_api' do
  let(:toggl_api) do
    double(:toggl_api).tap do |api|
      allow(api).to receive(:list_teams) { all_teams }
      allow(api).to receive(:list_all_members) { all_members }
      allow(api).to receive(:list_team_members).with(team1['id']) { team1_members }
      allow(api).to receive(:list_team_members).with(team2['id']) { team2_members }
      allow(api).to receive(:list_all_tasks) { all_tasks }
    end
  end

  let(:team1) do
    {
      'id' => '1',
      'name' => 'Team1',
    }
  end

  let(:team2) do
    {
      'id' => '2',
      'name' => 'Team2',
    }
  end

  let(:member1) do
    {
      'id' => '101',
      'uid' => '1',
      'email' => 'email_1@gmail.com',
    }
  end

  let(:member2) do
    {
      'id' => '102',
      'uid' => '2',
      'email' => 'email_2@gmail.com',
    }
  end

  let(:member3) do
    {
      'id' => '103',
      'uid' => '1',
      'email' => 'email_3@gmail.com',
    }
  end

  let(:member4) do
    {
      'id' => '104',
      'uuid' => '3',
      'email' => 'member1@foo.pl',
    }
  end

  let(:team_member1) do
    {
      'id' => '201',
      'uid' => '1',
      'pid' => '1',
    }
  end

  let(:team_member2) do
    {
      'id' => '202',
      'uid' => '2',
      'pid' => '1',
    }
  end

  let(:team_member3) do
    {
      'id' => '203',
      'uid' => '3',
      'pid' => '2',
    }
  end

  let(:task_1) do
    {
      'pid' => '1',
      'name' => 'task_1',
    }
  end

  let(:task_2) do
    {
      'pid' => '2',
      'name' => 'task_2',
    }
  end

  let(:all_tasks) { [task_1, task_2] }
  let(:all_teams) { [team1, team2] }
  let(:all_members) { [member1, member2, member3, member4] }
  let(:team1_members) { [member1, member2] }
  let(:team2_members) { [member3] }
end
