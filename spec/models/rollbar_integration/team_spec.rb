require 'rails_helper'

RSpec.describe RollbarIntegration::Team do
  include_context 'rollbar_api'
  include_context 'data_guru'

  let(:team) { OpenStruct.new(id: 1, name: 'team1') }

  before(:each) do
    allow(DataGuru::Client).to receive(:new).and_return(data_guru)
  end

  describe '.from_api_request' do
    subject { described_class.from_api_request(rollbar_api, team) }
    it 'returns team object' do
      expect(subject).to be_a described_class
    end

    it 'creates team with name attribute' do
      expect(subject.name).to eq(team.name)
    end

    it 'creates team with members' do
      expect(subject.members).to match_array(['first.member', 'second.member'])
    end

    context 'one member has not corresponging yaml with email' do
      let(:existing_members) { [member1, member2, member5] }
      it 'not list that member in members' do
        expect(subject.members).to match_array(['first.member', 'second.member'])
      end
    end
  end
end
