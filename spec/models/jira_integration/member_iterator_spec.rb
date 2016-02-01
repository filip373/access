require 'rails_helper'

RSpec.describe JiraIntegration::MemberIterator do
  describe '#each' do
    subject(:iterator) { described_class.new(projects) }

    context 'with valid projects structure' do
      let(:projects) do
        {
          'AG': {
            developers: %w(dev.first),
          },
          'DG': {
            developers: %w(dev.second),
            qas: %w(qa.first),
          },
        }
      end

      it 'yields every member' do
        expect { |b| subject.each(&b) }.to yield_control.exactly(3).times
      end
    end

    context 'with invalid projects structure' do
      let(:projects) do
        {
          'AG': %w(dev.first),
          'DG': %w(dev.second),
        }
      end

      it 'fails with JiraIntegration::InvalidProjectsObject error' do
        expect { |b| subject.each(&b) }.to raise_error JiraIntegration::InvalidProjectsObject
      end
    end
  end
end
