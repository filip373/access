require 'rails_helper'

describe TogglIntegration::Api do
  describe '#remove_tasks_from_project' do
    let(:client) { spy(:client) }
    let(:api) { described_class.new('token', 'company') }

    before do
      allow(api).to receive(:toggl_client) { client }
    end

    it "doesn't call the client when tasks_ids are empty" do
      task_ids = []
      api.remove_tasks_from_project(task_ids)
      expect(client).to_not have_received(:update_tasks)
    end

    it 'calls the client when tasks_ids are included' do
      task_ids = [1, 2]
      expect(client).to receive(:update_tasks)
      api.remove_tasks_from_project(task_ids)
    end
  end
end
