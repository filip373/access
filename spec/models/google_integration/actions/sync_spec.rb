require 'rails_helper'

RSpec.describe GoogleIntegration::Actions::Sync do
  include_context 'data_guru'

  let(:api) { double(GoogleIntegration::Api) }

  describe 'now!' do
    let(:sync_changes) { ->(diff) { described_class.new(api).now!(diff) } }

    it "doensn't raise an error when diff hash is empty" do
      diff = {}
      expect { sync_changes.call(diff) }.to_not raise_exception
    end
  end
end
