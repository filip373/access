require 'rails_helper'

RSpec.describe HockeyAppIntegration::Actions::Diff do
  include_context 'hockeyapp_api'
  include_context 'data_guru'

  let(:user_repo) { UserRepository.new(data_guru.members) }
  let(:dg_apps) do
    HockeyAppIntegration::App.all_from_dataguru(data_guru.hockeyapp_apps, user_repo)
  end

  let(:api_apps) do
    HockeyAppIntegration::App.all_from_api(hockeyapp_api, user_repo)
  end

  subject do
    described_class.new(dg_apps, api_apps).now!
  end

  it 'returns a hash' do
    expect(subject).to be_a_kind_of(Hash)
  end

  context 'diffing members' do
    context 'from dataguru to hockeyapp' do
      let(:user_emails) { subject[:add_users][dg_apps.first][:members].first.emails }

      it 'shows users that are not in hockeyapp' do
        expect(user_emails).to include('third.member@mail.com')
      end
    end

    context 'from hockeyapp to dataguru' do
      let(:user_emails) { subject[:remove_users][dg_apps.first][:members].first.emails }

      it 'shows users that are not in data guru' do
        expect(user_emails).to include('fourth.member@mail.com')
      end
    end
  end

  context 'diffing teams' do
    context 'from dataguru to hockeyapp' do
      it 'shows teams that are not in hockeyapp' do
        expect(subject[:add_teams][dg_apps.first]).to eq(['Team2'])
      end
    end

    context 'from hockeyapp to dataguru' do
      it 'shows teams that are not in data guru' do
        expect(subject[:remove_teams][dg_apps.first]).to eq(['Team4'])
      end
    end
  end

  context 'missing apps' do
    context 'in data guru' do
      it { expect(subject[:missing_dg_apps]).to eq([api_apps.last]) }
    end
    context 'in hockeyapp' do
      it { expect(subject[:missing_api_apps]).to eq(['App2']) }
    end
  end
end
