require 'rails_helper'

RSpec.describe CalculateDiffStrategist do
  include_context 'data_guru'

  let(:label) { :toggl }
  let(:session_token) { 'some-random-token' }
  let(:controller) { double('Controller') }
  subject do
    described_class.new(
      controller: controller,
      label: label,
      data_guru: data_guru,
      session_token: session_token,
    )
  end

  describe 'running with correct label' do
    before do
      allow(controller).to receive(:redirect_to)
    end

    context 'without diff cached' do
      it 'runs correct worker' do
        Rails.cache.delete('toggl_performing_diff')
        allow(TogglWorkers::DiffWorker).to receive(:perform_later)
        subject.call
        expect(TogglWorkers::DiffWorker).to have_received(:perform_later)
      end
    end

    context 'with diff cached' do
      it 'redirects to correct path' do
        allow(TogglWorkers::DiffWorker).to receive(:perform_later)
        Rails.cache.write('toggl_performing_diff', false)
        subject.call
        expect(controller).to have_received(:redirect_to).with('/toggl/show_diff')
      end
    end
  end
end
