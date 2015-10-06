RSpec.shared_context 'toggl_api' do
  let(:toggl_api) do
    double.tap do |api|
      allow(api).to receive(:list_teams) { all_teams }
      allow(api).to receive(:list_all_members) { all_members }
      allow(api).to receive(:list_team_members).with(team1['id']) { team1_members }
      allow(api).to receive(:list_team_members).with(team2['id']) { team2_members }
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

  let(:all_teams) { [team1, team2] }
  let(:all_members) { [member1, member2, member3] }
  let(:team1_members) { [member1, member2] }
  let(:team2_members) { [member3] }
end
