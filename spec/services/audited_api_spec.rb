require 'rails_helper'

RSpec.describe AuditedApi do
  let(:now) { Time.zone.parse('2015-12-04 12:00') }
  before { Timecop.freeze(now) }
  before { I18n.backend.store_translations(:en, dummy: { foo_bar_baz: '%{one} + %{two}' }) }
  before { I18n.backend.store_translations(:en, dummy: { fizz_bazz: 'name: %{object_with_name}' }) }
  after { Timecop.return }

  let(:user) { double(email: 'foo@bar.com', name: 'Foo Bar') }
  let(:dummy_instance) { Dummy.new }
  let(:buffer_dev) { BufferedLogDevice.new }
  let(:logger) { AuditLogger.new(buffer_dev) }
  let(:instance) { described_class.new(dummy_instance, user, logger) }

  describe 'sending messages to proxied object' do
    subject { instance.foo_bar_baz(1, 1) }

    it 'logs the message' do
      subject
      expect(buffer_dev.buffer).to eq(
        "#{now}: [#{dummy_instance.namespace}] #{user.email} -- OK -- 1 + 1\n",
      )
    end

    it 'returns the proxied method response' do
      expect(subject).to eq 2
    end

    context 'proxied method argument responds to name' do
      let(:struct) { Struct.new(:name) }
      subject { instance.fizz_bazz(struct.new('Szymon')) }

      it 'logs the the name' do
        subject
        expect(buffer_dev.buffer).to eq(
          "#{now}: [#{dummy_instance.namespace}] #{user.email} -- OK -- name: Szymon\n",
        )
      end
    end
  end

  describe 'missing action translations' do
    subject { instance.foo(1, 2) }
    context 'when env is development' do
      before { allow(Rails).to receive(:env).and_return('development'.inquiry) }

      it 'raises an exception' do
        expect { subject }.to raise_error I18n::MissingTranslationData
      end
    end

    context 'when env is production' do
      before { allow(Rails.env).to receive(:production?).and_return(true) }

      it 'logs a warning' do
        subject
        log_content = "translation missing: en.#{dummy_instance.namespace}.foo"
        expect(buffer_dev.buffer).to eq(
          "#{now}: [#{dummy_instance.namespace}] #{user.email} -- #{log_content}\n",
        )
      end
    end
  end

  describe 'missing interpolation argument in action translation' do
    before { I18n.backend.store_translations(:en, dummy: { foo_bar_baz: '%{first} + %{two}' }) }
    subject { instance.foo_bar_baz(1, 1) }

    context 'when in development env' do
      it 'raises an exception' do
        expect { subject }.to raise_error I18n::MissingInterpolationArgument
      end
    end

    context 'when in production env' do
      before { allow(Rails.env).to receive(:production?).and_return(true) }

      it 'logs a warning' do
        subject
        log_content = 'missing interpolation argument :first in "%{first} + %{two}" ({:one=>"1", :two=>"1"} given)'
        expect(buffer_dev.buffer).to eq(
          "#{now}: [#{dummy_instance.namespace}] #{user.email} -- #{log_content}\n",
        )
      end
    end
  end
end
