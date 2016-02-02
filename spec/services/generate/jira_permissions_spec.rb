require 'rails_helper'

describe Generate::JiraPermissions do
  include_context 'jira_api'

  describe '#call' do
    let(:permissions_dir) { Rails.root.join('spec/tmp/permissions') }
    let(:jira_dir) { permissions_dir.join('jira_projects') }

    let(:accessguru_path) { jira_dir.join('accessguru.yml') }
    let(:dataguru_path) { jira_dir.join('dataguru.yml') }
    let(:netguru_flow_path) { jira_dir.join('netguru_flow.yml') }

    let(:accessguru_yaml) { YAML.load(File.open(accessguru_path)) }
    let(:dataguru_yaml) { YAML.load(File.open(dataguru_path)) }
    let(:netguru_flow_yaml) { YAML.load(File.open(netguru_flow_path)) }

    before do
      described_class.new(jira_api, permissions_dir).call
    end

    after do
      FileUtils.rm_rf(permissions_dir)
    end

    it 'creates project files' do
      expect(File.exist?(accessguru_path)).to be_truthy
      expect(File.exist?(dataguru_path)).to be_truthy
      expect(File.exist?(netguru_flow_path)).to be_truthy
    end

    it 'sets AccessGuru project attributes' do
      expect(accessguru_yaml).to eq(
        name: 'AccessGuru',
        key: 'AG',
        developers: %w(dev.third),
        qas: %w(qa.second),
        pms: %w(pm.first),
        client_developers: %w(external/clientdev.first),
        clients: %w(external/client.first),
      )
    end

    it 'sets DataGuru project attributes' do
      expect(dataguru_yaml).to eq(
        name: 'DataGuru',
        key: 'DG',
        developers: %w(dev.second),
        qas: %w(qa.first),
        pms: %w(pm.first),
        client_developers: [],
        clients: [],
      )
    end

    it 'sets NETGURU FLOW project attributes' do
      expect(netguru_flow_yaml).to eq(
        name: 'NETGURU FLOW',
        key: 'NFG',
        developers: [],
        qas: [],
        pms: [],
        client_developers: [],
        clients: [],
      )
    end
  end
end
