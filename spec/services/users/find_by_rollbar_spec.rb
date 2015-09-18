require 'rails_helper'

describe Users::FindByRollbar do
  let(:users_data) do
    {
      'group_one' => {
        'janusz' => { 'name' => 'Janusz Nowak',
                      'github' => '13art', 'rollbar' => '13art' },
        'marian' => { 'name' => 'Marian Nowak', 'github' => '76marekm' },
      },
      'group_two' => {
        'andrzej' => { 'name' => 'Andrzej Nowak', 'github' => '13art' },
      },
      'default_group' => {
        'parowka' => { 'name' => 'Parówka Nowak', 'github' => '13art' },
      },
      'michal.nowak' => { 'name' => 'Michał Nowak', 'github' => 'mnowak',
                          'rollbar' => 'mnowak' },
    }
  end

  describe '#call' do
    context 'sought user is outside of any grop' do
      subject do
        described_class.new(users_data: users_data, username: 'mnowak').call
      end
      let(:expected_user) do
        { full_name: 'Michał Nowak', github: 'mnowak', rollbar: 'mnowak',
          name: 'michal.nowak' }
      end
      it 'returns user' do
        expect(subject).to have_attributes(expected_user)
      end

      it 'is a User' do
        expect(subject).to be_a User
      end
    end

    context 'sought user is nested in a group' do
      subject do
        described_class.new(users_data: users_data, username: '13art').call
      end
      let(:expected_user) do
        { full_name: 'Janusz Nowak', github: '13art', rollbar: '13art',
          name: 'janusz' }
      end
      it 'returns user' do
        expect(subject).to have_attributes(expected_user)
      end
    end

    context 'sought user not exist' do
      subject do
        described_class.new(users_data: users_data, username: 'not_exist').call
      end
      it 'returns false' do
        expect(subject).to be_falsy
      end
    end
  end
end
