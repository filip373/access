require 'rails_helper'

RSpec.describe BaseDiff do
  let(:team_alfa) { GithubIntegration::Team.new('Alfa', %w(old-member), %w(old-repo), 'push') }
  let(:team_beta) { GithubIntegration::Team.new('Beta', %w(older-member), %w(older-repo), 'push') }
  let(:api_team_alfa) { GithubIntegration::Team.new('Alfa', %w(new-member), %w(new-repo), 'pull') }
  let(:api_team_delta) { GithubIntegration::Team.new('Delta', %w(new-member), %w(new-repo), 'push') }

  let(:current_teams) { [team_alfa, team_beta] }
  let(:teams_from_api) { [api_team_alfa, api_team_delta] }

  subject(:diff_obj) { described_class.new(current_teams, teams_from_api) }
  before { diff_obj.diff! }

  shared_examples 'diff hash' do
    it { is_expected.to be_a Hash }
    it 'contains items that were removed' do
      expect(subject).to eq expected_hash
    end
  end

  describe '#diff!' do
    context 'remove hash' do
      let(:expected_hash) do
        {
          'Alfa' => {
            members: %w(old-member),
            repos: %w(old-repo),
            permission: 'push',
          },
          'Beta' => {
            members: %w(older-member),
            repos: %w(older-repo),
            permission: 'push',
          },
        }
      end
      subject { diff_obj.remove_hash }

      it_behaves_like 'diff hash'
    end

    context 'add hash' do
      let(:expected_hash) do
        {
          'Alfa' => {
            members: %w(new-member),
            repos: %w(new-repo),
            permission: 'pull',
          },
          'Delta' => {
            members: %w(new-member),
            repos: %w(new-repo),
            permission: 'push',
          },
        }
      end
      subject { diff_obj.add_hash }

      it_behaves_like 'diff hash'
    end
  end
end
