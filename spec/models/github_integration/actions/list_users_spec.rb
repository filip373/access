require 'rails_helper'

RSpec.describe GithubIntegration::Actions::ListUsers do
  include_context 'gh_teams'

  subject do
    described_class.new(github_users, dg_users, gh_teams, category).call
  end

  let(:github_users) { [{'login' => 'user1', 'html_url' => 'asdf'}] }
  let(:dg_users) { users }
  let(:gh_teams) { github_teams }
  let(:category) { :category }

  context 'github users are empty' do
    let(:github_users) { [] }
    it { expect(subject).to be_a Array }
    it { expect(subject).to be_empty }
  end

  context 'github users are not empty' do
    it { expect(subject).to be_a Hash }
    it { expect(subject).not_to be_empty }

    it 'returned hash has two items' do
      expect(subject.count).to eq 2
    end

    it 'returned hash contains category key' do
      expect(subject).to have_key(category)
    end

    it 'returned hash contains users missing from dataguru' do
      expect(subject).to have_key(:missing_from_dg)
    end
  end

  context 'listing teamless users' do
    let(:category) { :teamless }
    let(:github_users) { [{'login' => 'teamless', 'html_url' => 'github_link'}] }
    let(:dg_users) do
      users << OpenStruct.new(
        id: 'teamless.user',
        name: 'Teamless Dude',
        github: 'teamless',
        emails: ['teamless.dude@mail.com'],
      )
    end

    context 'when user is not assigned to team in dataguru' do
      let(:teamless_user) do
        ListedUser.new(
          github: 'teamless',
          name: 'Teamless Dude',
          emails: ['teamless.dude@mail.com']
        )
      end

      before do
        teamless_user.html_url = 'github_link'
        teamless_user.github_teams = ''
      end

      it 'returns teamless users' do
        teamless_users = subject.fetch(:teamless)
        expect(teamless_users.count).to eq 1
        expect(teamless_users.first.as_json).to eq teamless_user.as_json
      end

      it 'uses proper class for listed user' do
        expect(subject.fetch(:teamless).first).to be_a ListedUser
      end
    end

    context 'when user is assigned to team in dataguru' do
      before do
        gh_teams << OpenStruct.new(
          id: 'team3',
          members: ['teamless.user'],
          repos: ['random_repo'],
          permissions: 'push'
        )
      end

      it 'does not list this user' do
        expect(subject.fetch(:teamless)).to be_empty
      end
    end

    context 'when user is missing from dataguru' do
      before { dg_users.reject!{|u| u.github == 'teamless'} }

      it 'lists that user' do
        expect(subject.fetch(:missing_from_dg).count).to eq 1
      end

      it 'uses proper class for that user' do
        expect(subject.fetch(:missing_from_dg).first)
          .to be_a DataGuruNilUser
      end
    end
  end

  context 'listing different category' do
    let(:category) { :unsecure }
    let(:github_users) do
      [{'login' => 'unsecure1', 'html_url' => 'github_link1'},
       {'login' => 'unsecure2', 'html_url' => 'github_link2'}
      ]
    end
    let(:dg_users) do
      users.push(OpenStruct.new(
        id: 'unsecure.user1',
        name: 'Another Dude',
        github: 'unsecure1',
        emails: ['unsecure.dude1@mail.com'],
      ), OpenStruct.new(
        id: 'unsecure.user2',
        name: 'Random Dude',
        github: 'unsecure2',
        emails: ['unsecure.dude2@mail.com']
      )
      )
    end

    before do
      gh_teams << OpenStruct.new(
        id: 'team3',
        members: ['unsecure.user1'],
        repos: ['random_repo'],
        permissions: 'push'
      )
    end

    it 'does not reject users assigned to teams in dataguru' do
      expect(subject.fetch(category).count).to eq 2
    end
  end
end
