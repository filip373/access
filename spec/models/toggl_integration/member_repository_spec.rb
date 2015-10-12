require 'rails_helper'

describe TogglIntegration::MemberRepository do
  include_context 'toggl_api'

  let(:repository) { described_class.build_from_toggl_api(toggl_api) }

  describe '#all' do
    it 'returns all members' do
      expect(repository.all.count).to eq 3
    end
  end

  describe '#find_by_emails' do
    context 'member exists' do
      it 'returns member with given email' do
        member = repository.find_by_emails(member1['email'])
        expect(member.emails).to include member1['email']
        expect(member.toggl_id).to eq member1['uid'].to_i
      end
    end

    context 'member does not exist' do
      it 'returns nil' do
        member = repository.find_by_emails('asakdkf4848@gmail.com')
        expect(member).to be_nil
      end
    end
  end
end
