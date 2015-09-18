require 'rails_helper'

RSpec.describe RollbarIntegration::Team do
  include_context 'rollbar_api'

  let(:team) { OpenStruct.new(id: 1, name: 'team1') }

  describe '.from_api_request' do
    subject { described_class.from_api_request(rollbar_api, team) }
    it 'returns team object' do
      expect(subject).to be_a described_class
    end

    it 'creates team with name attribute' do
      expect(subject.name).to be_present
      expect(subject.name).to eq(team.name)
    end

    it 'creates team with members attribute' do
      expect(subject.members).to be_present
      expect(subject.members).to be_a Array
      expect(subject.members).to match_array(['first.member', 'second.member'])
    end
  end
end
