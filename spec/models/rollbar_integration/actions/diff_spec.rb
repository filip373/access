require 'rails_helper'

RSpec.describe RollbarIntegration::Actions::Diff do
  include_context 'rollbar_api'
  include_context 'data_guru'

  before(:each) do
    Celluloid.shutdown
    Celluloid.boot
    allow(DataGuru::Client).to receive(:new).and_return(data_guru)
    allow(RollbarIntegration::Api).to receive(:new).and_return(rollbar_api)
  end

  let(:new_team) do
    expected_teams.find { |team| team.name == 'team2' }
  end

  it 'is returns a hash' do
    expect(described_class.new(expected_teams, existing_teams).now!).to be_a(Hash)
  end

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
