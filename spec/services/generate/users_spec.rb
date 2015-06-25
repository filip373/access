require 'rails_helper'

describe Generate::Users do
  include_context 'gh_api'
  include_context 'google_api'

  describe '.new' do
    let(:instantiated_user) do
      described_class.new(
        instance_double('GoogleApi'),
        instance_double('GithubApi'),
        Rails.root.join('path'),
      )
    end

    it { expect { instantiated_user.google_api }.to raise_error(NoMethodError) }
    it { expect { instantiated_user.gh_api }.to raise_error(NoMethodError) }
    it { expect { instantiated_user.users_dir }.to raise_error(NoMethodError) }
  end

  describe '#call' do
    let(:members) do
      [
        Hashie::Mash.new(
          name: 'first.member',
          primaryEmail: 'first.member@netguru.pl',
          name: { fullName: 'First Member' },
        ),
        Hashie::Mash.new(
          name: 'second.member',
          primaryEmail: 'second.member@external.pl',
          name: { fullName: 'Second Member' },
        ),
        Hashie::Mash.new(
          name: 'fifth.member',
          primaryEmail: 'fifth.member@netguru.pl',
          name: { fullName: 'Fifth Member' },
        ),
      ]
    end

    let(:gh_org_members) do
      [
        { 'login' => 'frst.mbr' },
        { 'login' => 'scnd.mbr' },
        { 'login' => 'thrd.mbr' },
        { 'login' => 'frth.mbr' },
      ]
    end
    let(:users_dir) { Rails.root.join('spec/tmp/permissions') }
    let(:first_member_path) { users_dir.join('users/netguru/first.member.yml') }
    let(:second_member_path) { users_dir.join('users/external/second.member.yml') }
    let(:third_member_path) { users_dir.join('users/external/third.member.yml') }
    let(:fourth_member_path) { users_dir.join('users/external/frth.mbr.yml') }
    let(:fifth_member_path) { users_dir.join('users/netguru/fifth.member.yml') }

    let(:first_member_yaml) { YAML.load(File.open(first_member_path)) }
    let(:second_member_yaml) { YAML.load(File.open(second_member_path)) }
    let(:third_member_yaml) { YAML.load(File.open(third_member_path)) }
    let(:fourth_member_yaml) { YAML.load(File.open(fourth_member_path)) }
    let(:fifth_member_yaml) { YAML.load(File.open(fifth_member_path)) }

    before do
      described_class.new(google_api, gh_api, users_dir).call
    end

    after do
      FileUtils.rm_rf(users_dir)
    end

    it 'creates file with company user' do
      expect(File.exist?(first_member_path)).to be_truthy
    end

    it 'creates file with external user' do
      expect(File.exist?(second_member_path)).to be_truthy
    end

    it 'creates files with proper attributes' do
      expect(first_member_yaml['name']).to eq 'First Member'
      expect(second_member_yaml['name']).to eq 'Second Member'
      expect(first_member_yaml['github']).to eq 'frst.mbr'
      expect(second_member_yaml['github']).to eq 'scnd.mbr'
    end

    context 'There is a github user (thrd.mbr) who has no email' do
      it 'creates a yaml with name as sligified name' do
        expect(File.exist?(third_member_path)).to be_truthy
      end

      it 'has attribute name as github full name' do
        expect(third_member_yaml['name']).to eq 'Third Member'
      end
    end

    context 'There is a github user (frth.mbr) who has no email and no full name' do
      it 'creates a yaml with name as github login' do
        expect(File.exist?(fourth_member_path)).to be_truthy
      end

      it 'has attribute name as github login capitalized' do
        expect(fourth_member_yaml['name']).to eq 'Frth.mbr'
      end
    end

    context 'There is no github user match for google user' do
      it 'creates a yaml with no github login' do
        expect(File.exist?(fifth_member_path)).to be_truthy
        expect(fifth_member_yaml['github']).to eq ''
      end
    end
  end
end
