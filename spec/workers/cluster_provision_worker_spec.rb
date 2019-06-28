# frozen_string_literal: true

require 'spec_helper'

describe ClusterProvisionWorker do
  describe '#perform' do
    context 'when provider type is gcp' do
      let(:cluster) { create(:cluster, provider_type: :gcp, provider_gcp: provider) }
      let(:provider) { create(:cluster_provider_gcp, :scheduled) }

      it 'provision a cluster' do
        expect_any_instance_of(Clusters::Gcp::ProvisionService).to receive(:execute)

        described_class.new.perform(cluster.id)
      end
    end

    context 'when provider type is user' do
      let(:cluster) { create(:cluster, :provided_by_user, managed: false) }

      it 'does not provision a cluster' do
        expect_any_instance_of(Clusters::Gcp::ProvisionService).not_to receive(:execute)

        described_class.new.perform(cluster.id)
      end

      it 'does not create a cluster role if the cluster is not managed rbac' do
        expect_any_instance_of(::Gitlab::Kubernetes::KubeClient).not_to receive(:update_cluster_role)

        described_class.new.perform(cluster.id)
      end

      context 'when the cluster is a managed rbac cluster' do
        before do
          cluster.update(managed: true)
        end

        it 'creates an aggregated to edit cluster role for the serving.knative.dev API group' do
          expect_any_instance_of(::Gitlab::Kubernetes::KubeClient).to receive(:update_cluster_role).with(
            having_attributes(
              metadata: having_attributes(labels: having_attributes('rbac.authorization.k8s.io/aggregate-to-edit' => 'true')),
              rules: array_including(having_attributes(apiGroups: %w(serving.knative.dev)))
            )
          ).and_return(true)

          described_class.new.perform(cluster.id)
        end
      end
    end

    context 'when cluster does not exist' do
      it 'does not provision a cluster' do
        expect_any_instance_of(Clusters::Gcp::ProvisionService).not_to receive(:execute)

        described_class.new.perform(123)
      end

      it 'does not attempt to create a cluster role' do
        expect_any_instance_of(::Gitlab::Kubernetes::KubeClient).not_to receive(:update_cluster_role)

        described_class.new.perform(123)
      end
    end
  end
end
