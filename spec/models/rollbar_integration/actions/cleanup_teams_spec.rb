require 'rails_helper'

RSpec.describe RollbarIntegration::Actions::CleanupTeams do
  include_context 'rollbar_api'

  let(:expected_teams) { RollbarIntegration::Teams.all }
  let(:team1) do
    Hashie::Mash.new(
      name: 'team1',
    )
  end
  let(:team3) do
    Hashie::Mash.new(
      name: 'team3',
    )
  end
  let(:rollbar_api) do
    double.tap do |api|
      allow(api).to receive(:remove_team) do |team_id|
        m_existing_teams.delete_if { |t| t.id == team_id }
      end
    end
  end

  let(:m_existing_teams) { existing_teams.push(team3) }

  subject { described_class.new(expected_teams, m_existing_teams, rollbar_api) }

  context '#stranded_teams' do
    it { expect(subject.stranded_teams).to be_a Array }
    it { expect(subject.stranded_teams).to include team3 }
    it { expect(subject.stranded_teams).to_not include team1 }
  end

  context '#now!' do
    before(:each) { subject.now! }

    it 'removes team3' do
      expect(m_existing_teams).to_not include team3
    end

    it 'use fire remove_team on github api' do
      expect(rollbar_api).to have_received(:remove_team).with(team3.id)
    end
  end
end
