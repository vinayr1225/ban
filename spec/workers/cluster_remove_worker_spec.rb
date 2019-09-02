# frozen_string_literal: true

require 'spec_helper'

describe ClusterRemoveWorker do
  describe '#perform' do
    subject { described_class.new.perform(cluster.id) }

    let!(:cluster) { create(:cluster, provider_type: :gcp) }

    context 'cluster has no applications or roles' do
      it 'deletes cluster' do
        expect { subject }.to change { Clusters::Cluster.count }.by(-1)
      end
    end

    context 'cluster has roles' do
    end

    context 'cluster has applications' do
    end
  end
end
