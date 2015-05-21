require 'rails_helper'

describe User do
  let(:users_data) do
    {
      'group_one' => {
        'janusz' => { 'name' => 'Janusz Nowak', 'github' => '13art' },
        'marian' => { 'name' => 'Marian Nowak', 'github' => '76marekm' },
      },
      'group_two' => {
        'andrzej' => { 'name' => 'Andrzej Nowak', 'github' => '13art' },
      },
      'default_group' => {
        'parowka' => { 'name' => 'Parówka Nowak', 'github' => '13art' },
      },
      'michal.nowak' => { 'name' => 'Michał Nowak', 'github' => 'mnowak' },
    }
  end

  let(:company_name) { 'default_group' }

  before do
    allow(User).to receive(:company_name) { company_name }
    allow(User).to receive(:users_data) { users_data }
  end

  it 'finds user in default group' do
    expect(User.find('parowka')).to be
  end

  it 'finds user nested in other group' do
    expect(User.find('group_one/janusz')).to be
  end

  it 'finds user defined outside groups' do
    expect(User.find('michal.nowak')).to be
  end

  it 'does not find user if he is not defined' do
    expect(User.find('herbatka')).not_to be
  end
end
