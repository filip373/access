require 'rails_helper'

describe ApplicationController do
  describe '#jira_credentials' do
    let(:now) { Time.zone.parse('12.01.2016 12:00') }
    before { Timecop.freeze(now) }
    before { session[:jira_credentials] = credentials }
    after { Timecop.return }
    subject { controller.jira_credentials }

    context 'when User is signed in through Jira' do
      let(:credentials) { { token: 'token', secret: 'secret', expires_at: now + 1.day } }
      it { is_expected.to eq OpenStruct.new(credentials) }
    end

    context 'when User is not signed in through Jira' do
      let(:credentials) { nil }
      it { is_expected.to be_nil }
    end

    context 'when token is expired' do
      let(:credentials) { { token: 'token', secret: 'secret', expires_at: now - 1.minute } }
      it { is_expected.to be_nil }
    end
  end
end
