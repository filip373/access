require 'rails_helper'

describe User do

  let(:user_data) { {
      "group_one" => {
        "janusz" => {"name" => "Janusz Nowak", "github" => "13art"},
        "marian" => {"name" => "Marian Nowak", "github" => "76marekm"},
      },
      "group_two" => {
        "andrzej" => {"name" => "Andrzej Nowak", "github" => "13art"}
      },
      "default_group" => {
        "parowka" => {"name" => "Parówka Nowak", "github" => "13art"}
      }
  } }

  let(:company_name) { 'default_group' }

  before do
    User.stub(
      company_name: company_name,
      users_data: user_data
    )
  end

  it "finds user in default group" do
    expect(User.find('parowka')).to be
  end

  it "finds user nested in other group" do
    expect(User.find('group_one/janusz')).to be
  end

  it "does not find user if he is not in groups" do
    expect(User.find('herbatka')).not_to be
  end
end
