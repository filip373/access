require 'rails_helper'

RSpec.describe GoogleIntegration::Actions::AccountsDiff do
  include_context 'google_api'

  subject { described_class.new(google_api).now! }

  it { is_expected.to be_a Array }
  it { is_expected.to_not be_nil }
end
