require 'rails_helper'

RSpec.describe GithubIntegration::Actions::CleanupMembers do
  include_context 'data_guru'
  include_context 'gh_api'

  subject { described_class.new(stranded_users, gh_api, 'company_name') }

  describe '#now!' do
    let(:stranded_users) do
      [DataGuruNilUser.new(
        'login' => 'user1',
        'html_url' => 'link'),
       DataGuruNilUser.new(
        'login' => 'user2',
        'html_url' => 'link2'),
      ]
    end

    let(:gh_org_members) do
      [{ 'login' => 'user1',
          'email' => 'user1@mail.com',
          'name' => 'User One'
       },
       { 'login' => 'user2',
          'email' => 'user2@mail.com',
          'name' => 'User Two'
       },
       { 'login' => 'user3',
          'email' => 'user3@mail.com',
          'name' => 'User Three'
       }
      ]
    end

    it 'removes stranded users from github' do
      expect{ subject.now! }.to change{ gh_api.list_org_members.count }.from(3).to(1)
    end

    it 'uses remove_member_from_org on github api' do
      expect(gh_api).to receive(:remove_member_from_org).with('user1', 'company_name')
      expect(gh_api).to receive(:remove_member_from_org).with('user2', 'company_name')
      subject.now!
    end
  end
end
