require 'spec_helper'

describe Gitlab::Metrics::Prometheus, :prometheus do
  let(:all_metrics) { Gitlab::Metrics }
  let(:registry) { all_metrics.registry }

  describe '#reset_registry!' do
    it 'clears existing metrics' do
      registry.counter(:test, 'test metric')

      expect(registry.metrics.size).to eq(1)

      all_metrics.reset_registry!

      expect(all_metrics.registry.metrics.size).to eq(0)
    end
  end
end
