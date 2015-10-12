require 'rails_helper'

RSpec.describe CollectionToHash do
  let(:team_alfa) { GithubIntegration::Team.new('Alfa', %w(jake), %w(rails), 'push') }
  let(:team_beta) { GithubIntegration::Team.new('Beta', %w(john), %w(sinatra), 'pull') }
  let(:teams) { [team_alfa, team_beta] }
  let(:expected_hash) do
    {
      'Alfa' => {
        members: %w(jake),
        repos: %w(rails),
        permission: 'push',
      },
      'Beta' => {
        members: %w(john),
        repos: %w(sinatra),
        permission: 'pull',
      },
    }
  end
  subject { described_class.call(teams) }

  it { is_expected.to eq expected_hash }
end
