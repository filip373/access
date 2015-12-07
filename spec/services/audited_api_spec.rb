require 'rails_helper'

RSpec.describe AuditedApi do
  let(:now) { Time.parse('2015-12-04 12:00') }
  before { Timecop.freeze(now) }
  after { Timecop.return }

  let(:dummy_instance) { Dummy.new }
  let(:buffer_dev) { BufferedLogDevice.new }
  let(:logger) { AuditLogger.new(buffer_dev) }
  let(:instance) { described_class.new(dummy_instance, logger) }

  describe '#method_missing' do
    subject { instance.foo_bar_baz(1, 1) }

    it 'proxies the call to the underlying method' do
      expect(dummy_instance).to receive(:foo_bar_baz).with(1, 1).and_call_original
      subject
    end

    it 'logs the message' do
      subject
      expect(buffer_dev.buffer).to eq(
        <<-EOS
INFO #{now}: [Dummy] Called method: foo_bar_baz(one, two)
  With args:    1, 1
  Got response: 2

        EOS
      )
    end

    it 'returns the proxied method response' do
      expect(subject).to eq 2
    end
  end
end
