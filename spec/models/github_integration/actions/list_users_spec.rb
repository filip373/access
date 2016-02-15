require 'rails_helper'

RSpec.describe GithubIntegration::Actions::ListUsers do
  include_context 'gh_teams'

  subject do
    described_class.new(github_users, dg_users, gh_teams, category).call
  end

  context 'listing no 2fa users' do
    let(:category) { :unsecure }

    let(:github_users) do
      [{'login' => 'unsecure', 'html_url' => 'github_link'},
       {'login' => 'unsecure2', 'html_url' => 'some_link'},
       {'login' => 'unsecure3', 'html_url' =>  'another_link'}]
    end

    let(:dg_users) do
      users.push(OpenStruct.new(
        id: 'unsecure.user',
        name: 'Unsecure Dude',
        github: 'unsecure',
        emails: ['unsecure.dude@mail.com']
      ), OpenStruct.new(
        id: 'unsecure.user2',
        name: 'Another User',
        github: 'unsecure2',
      ))
    end

    let(:gh_teams) do
      github_teams << OpenStruct.new(
        id: 'team5',
        members: ['unsecure.user'],
        repos: ['some_repo'],
        permissions: 'push'
      )
    end

    it 'returns users without 2fa' do
      expect(subject.count).to eq 3
    end

  end

  context 'list teamless users' do
    let(:category) { :teamless }

    let(:github_users) do
      [{'login' => 'teamless', 'html_url' => 'github_link'}]
    end

    let(:dg_users) do
      users << OpenStruct.new(
        id: 'teamless.user',
        name: 'Teamless Dude',
        github: 'teamless',
        emails: ['teamless.dude@mail.com'],
      )
    end

    let(:gh_teams) do
      github_teams
    end

    let(:teamless_user) do
      ListedUser.new(
        github: 'teamless',
        name: 'Teamless Dude',
        emails: ['teamless.dude@mail.com'],
      )
    end

    context 'with user teamless on github' do
      context 'and teamless in data_guru' do
        before do
          teamless_user.html_url = 'github_link'
          teamless_user.github_teams = ''
        end

        it 'returns teamless users' do
          teamless_users = subject
          expect(teamless_users.count).to eq 1
          expect(teamless_users.first.as_json).to eq teamless_user.as_json
        end

        it 'returns an array' do
          expect(subject).to be_an_instance_of(Array)
        end

        it 'returned array contains TeamlessUser instances' do
          expect(subject.first)
            .to be_an_instance_of(ListedUser)
        end
      end

      context 'and assigned to team in data_guru' do
        before do
          gh_teams << OpenStruct.new(
            id: 'team3',
            members: ['teamless.user'],
            repos: ['random_repo'],
            permissions: 'push'
          )
        end

        it 'does not list this user' do
          expect(subject.count).to eq 0
        end
      end

      context 'user not in data_guru' do
        before do
          dg_users.reject!{|u| u.github == 'teamless'}
        end

        it 'lists that user' do
          expect(subject.count).to eq 1
        end

        it 'returns data guru nil user' do
          expect(subject.first)
            .to be_an_instance_of(DataGuruNilUser)
        end
      end
    end

    context 'user is assigned to team on github' do
      let(:github_users) { [] }

      it 'does not list this user' do
        expect(subject.count).to eq 0
      end
    end
  end
end
