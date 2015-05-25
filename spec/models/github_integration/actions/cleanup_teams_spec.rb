require 'rails_helper'

RSpec.describe GithubIntegration::Actions::CleanupTeams do
  let(:expected_teams) { GithubIntegration::Teams.all }
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
  let(:gh_teams) { [team1, team3] }
  let(:gh_api) do
    double.tap do |api|
      allow(api).to receive(:remove_team) do |team|
        gh_teams.delete team
      end
    end
  end

  subject { described_class.new(expected_teams, gh_teams, gh_api) }

  context '#stranded_teams' do
    it { expect(subject.stranded_teams).to be_a Array }
    it { expect(subject.stranded_teams).to include team3 }
    it { expect(subject.stranded_teams).to_not include team1 }
  end

  context '#now!' do
    before(:each) { subject.now! }

    it 'removes team3' do
      expect(gh_teams).to_not include team3
    end

    it 'use fire remove_team on github api' do
      expect(gh_api).to have_received(:remove_team).with(team3)
    end
  end
end
