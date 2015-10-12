require 'rails_helper'

RSpec.describe GithubIntegration::Team do
  subject(:team) { described_class.new('A-Team', %w(member), %w(repo), 'push') }

  shared_examples 'team object' do
    before do
      allow(described_class).to receive(:api_team_members) { %w(member) }
      allow(described_class).to receive(:api_team_repos) { %w(repo) }
    end

    it { is_expected.to be_a described_class }
    it 'initializes object correctly' do
      expect(subject.name).to eq 'A-Team'
      expect(subject.members).to eq %w(member)
      expect(subject.repos).to eq %w(repo)
      expect(subject.permission).to eq 'push'
    end
  end

  describe '.from_api_request' do
    let(:client) { double }
    subject(:team_from_api) { described_class.from_api_request(client, team) }

    it_behaves_like 'team object'
  end

  describe '.from_storage' do
    let(:team) { double(id: 'A-Team', members: %w(member), repos: %w(repo), permission: 'push') }
    subject(:team_from_storage) { described_class.from_storage(team) }

    it_behaves_like 'team object'
  end

  # Not sure about those specs - they basically mimic the implementation
  # We could either hard code hash/yaml here or just drop those specs altogether.
  describe '#to_h' do
    let(:expected_hash) do
      {
        name: team.name,
        members: team.members,
        repos: team.repos,
        permission: team.permission,
      }
    end
    subject { team.to_h }

    it { is_expected.to eq expected_hash }
  end

  describe '#to_yaml' do
    let(:expected_yaml) do
      {
        permission: team.permission,
        members: team.members,
        repos: team.repos,
      }.stringify_keys.to_yaml
    end
    subject { team.to_yaml }

    it { is_expected.to eq expected_yaml }
  end
end
