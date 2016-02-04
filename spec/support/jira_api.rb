RSpec.shared_context 'jira_api' do
  let(:projects) do
    [
      OpenStruct.new(name: 'AccessGuru', key: 'AG') { define_method(:attributes) { to_h } },
      OpenStruct.new(name: 'DataGuru', key: 'DG') { define_method(:attributes) { to_h } },
      OpenStruct.new(name: 'NETGURU FLOW', key: 'NFG') { define_method(:attributes) { to_h } },
    ]
  end

  let(:roles) do
    {
      'AG' => {
        'Developers' => 'AG-developers',
        'PM Team' => 'AG-pms',
        'QA Team' => 'AG-qas',
        'Client Dev' => 'AG-client-devs',
        'Clients' => 'AG-clients',
      },
      'DG' => {
        'Developers' => 'DG-developers',
        'PM Team' => 'DG-pms',
        'QA Team' => 'DG-qas',
        'Client Dev' => 'DG-client-devs',
        'Clients' => 'DG-clients',
      },
      'NFG' => {
        'Developers' => 'NFG-developers',
        'PM Team' => 'NFG-pms',
        'QA Team' => 'NFG-qas',
        'Client Dev' => 'NFG-client-devs',
        'Clients' => 'NFG-clients',
      },
    }
  end

  let(:user_type) { 'atlassian-user-role-actor' }

  let(:role_members) do
    {
      'AG-developers' => {
        'actors' => [{ 'name' => 'dev.third', 'type' => user_type }],
      },
      'AG-qas' => {
        'actors' => [{ 'name' => 'qa.second', 'type' => user_type }],
      },
      'AG-pms' => {
        'actors' => [{ 'name' => 'pm.first', 'type' => user_type }],
      },
      'AG-client-devs' => {
        'actors' => [{ 'name' => 'clientdev.first', 'type' => user_type }],
      },
      'AG-clients' => {
        'actors' => [{ 'name' => 'client.first', 'type' => user_type }],
      },

      'DG-developers' => {
        'actors' => [{ 'name' => 'dev.second', 'type' => user_type }],
      },
      'DG-qas' => {
        'actors' => [{ 'name' => 'qa.first', 'type' => user_type }],
      },
      'DG-pms' => {
        'actors' => [{ 'name' => 'pm.first', 'type' => user_type }],
      },
      'DG-client-devs' => {
        'actors' => [],
      },
      'DG-clients' => {
        'actors' => [],
      },

      'NFG-developers' => { 'actors' => [] },
      'NFG-qas' => { 'actors' => [] },
      'NFG-pms' => { 'actors' => [] },
      'NFG-client-devs' => { 'actors' => [] },
      'NFG-clients' => { 'actors' => [] },
    }
  end

  let(:jira_api) do
    double('JiraIntegration::Api').tap do |d|
      allow(d).to receive(:projects) { projects }
      allow(d).to receive(:roles_for).with(instance_of(String)) { |key| roles[key] }
      allow(d).to receive(:role_members).with(instance_of(String)) { |link| role_members[link] }
    end
  end
end
