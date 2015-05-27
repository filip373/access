require 'rails_helper'

RSpec.describe Storage do
  subject { Storage }
  let(:instance) { subject.instance }

  describe '.instance' do
    it { expect(instance).to be_a Storage }

    it 'call initialize once' do
      instance
      allow(subject).to receive(:new)
      Storage.instance
      expect(subject).to_not have_received(:new)
    end
  end

  describe '#data' do
    let(:data) { instance.data }

    it { expect(data).to be_a Hashie::Hash }
    it { expect(data).to respond_to(:github_teams) }
    it { expect(data.github_teams).to respond_to(:team1) }
    it { expect(data.github_teams).to respond_to(:team2) }
    it { expect(data.github_teams).to respond_to(:team_empty) }
    it { expect(data).to respond_to(:google_groups) }
    it { expect(data.google_groups).to respond_to(:group1) }
    it { expect(data.github_teams.team1).to respond_to(:members) }
    it { expect(data.github_teams.team1.members).to be_a Array }
    it { expect(data.github_teams.team1.repos).to be_a Array }
    it { expect(data.github_teams.team1.members.count).to eq(3) }

    it 'call build_tree once' do
      data
      allow(instance).to receive(:build_tree)
      Storage.instance.data
      expect(instance).to_not have_received(:build_tree)
    end
  end
end
