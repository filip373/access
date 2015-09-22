require 'rails_helper'

describe Users::FindByEmail do
  let(:users_data) do
    {
      'group_one' => {
        'janusz' => { 'name' => 'Janusz Nowak',
                      'github' => '13art', 'email' => '13art@foo.pl' },
        'marian' => { 'name' => 'Marian Nowak', 'github' => '76marekm' },
      },
      'group_two' => {
        'andrzej' => { 'name' => 'Andrzej Nowak', 'github' => '13art' },
      },
      'default_group' => {
        'parowka' => { 'name' => 'Parówka Nowak', 'github' => '13art' },
      },
      'michal.nowak' => { 'name' => 'Michał Nowak', 'github' => 'mnowak',
                          'email' => 'mnowak@foo.pl' },
    }
  end

  describe '#call' do
    context 'sought user is outside of any group' do
      subject do
        described_class
          .new(users_data: users_data, email: 'mnowak@foo.pl').call
      end
      let(:expected_attrubutes) do
        { full_name: 'Michał Nowak', github: 'mnowak', email: 'mnowak@foo.pl',
          name: 'michal.nowak' }
      end
      it 'returns user with attributes' do
        expect(subject).to have_attributes(expected_attrubutes)
      end

      it 'is a User' do
        expect(subject).to be_a User
      end
    end

    context 'sought user is nested in a group' do
      subject do
        described_class.new(users_data: users_data, email: '13art@foo.pl').call
      end
      let(:expected_attrubutes) do
        { full_name: 'Janusz Nowak', github: '13art', email: '13art@foo.pl',
          name: 'janusz' }
      end
      it 'returns user with attributes' do
        expect(subject).to have_attributes(expected_attrubutes)
      end
    end

    context 'sought user not exist' do
      subject do
        described_class.new(users_data: users_data, email: 'not_exist@foo.pl').call
      end
      it 'returns false' do
        expect(subject).to be_falsy
      end
    end
  end
end
