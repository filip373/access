require 'rails_helper'

RSpec.describe RollbarIntegration::Actions::Diff do
  include_context 'rollbar_api'

  before(:each) do
    Celluloid.shutdown
    Celluloid.boot
  end

  let(:expected_teams) { RollbarIntegration::Teams.all }
  let(:new_team) do
    expected_teams.find { |team| team.name == 'team2' }
  end

  subject { described_class.new(expected_teams, existing_teams, rollbar_api).now! }

  it { is_expected.to be_a Hash }

  context 'existing team' do
    context 'one member less in server than in yaml' do
      let(:existing_members) { [member1] }
      it { expect(subject[:add_members][team1]).to eq(['member2@foo.pl']) }
    end

    context 'one member more in server than in yaml' do
      let(:existing_members) { [member1, member2, member3] }
      it { expect(subject[:remove_members][team1]).to eq ['member3@foo.pl'] }
    end

    context 'one project less in server than in yaml' do
      let(:existing_projects) { [project1] }
      it { expect(subject[:add_projects][team1]).to eq ['project2'] }
    end

    context 'one project more in server than in yaml' do
      let(:existing_projects) { [project1, project2, project3] }
      it { expect(subject[:remove_projects][team1]).to eq ['project3'] }
    end
  end

  context 'new team' do
    it { expect(subject[:create_teams][new_team][:add_members]).to eq ['member3@foo.pl'] }
    it { expect(subject[:create_teams][new_team][:add_projects]).to eq ['project2'] }
  end

  context 'members in yml is empty' do
    let(:empty_members) { expected_teams.find { |t| t.name == 'team_empty' }.members }
    it { expect(empty_members).to be_a Array }
    it { expect(empty_members).to be_empty }
  end

  context 'projects in yml is empty' do
    let(:empty_repos) { expected_teams.find { |t| t.name == 'team_empty' }.projects }
    it { expect(empty_repos).to be_a Array }
    it { expect(empty_repos).to be_empty }
  end
end
