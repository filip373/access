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

  context 'members in yml is empty' do
    let(:empty_members) { expected_teams.find { |t| t.name == 'team_empty' }.members }
    it { expect(empty_members).to be_a Array }
    it { expect(empty_members).to be_empty }
  end

  context 'projects in yml is empty' do
    let(:empty_projects) { expected_teams.find { |t| t.name == 'team_empty' }.projects }
    it { expect(empty_projects).to be_a Array }
    it { expect(empty_projects).to be_empty }
  end
end
