# frozen_string_literal: true

require 'spec_helper'

describe ClusterRemoveWorker do
  describe '#perform' do
    subject { described_class.new.perform(cluster.id) }

    let!(:cluster) { create(:cluster, :project, provider_type: :gcp) }

    shared_examples 'removing cluster' do
      it 'sets cluster as removing' do
        expect_any_instance_of(Clusters::Cluster).to receive(:removing!)

        subject
      end
    end

    context 'when cluster has no applications or roles' do
      let(:kubeclient_intance_double) do
        instance_double(Gitlab::Kubernetes::KubeClient, delete_namespace: nil, delete_service_account: nil)
      end

      before do
        allow_any_instance_of(Clusters::Cluster).to receive(:kubeclient).and_return(kubeclient_intance_double)

        %i(staging production).each do |environment|
          environment = create(:environment, name: environment, project: cluster.project)

          create(:cluster_kubernetes_namespace,
            cluster: cluster,
            cluster_project: cluster.cluster_project,
            project: cluster.cluster_project.project,
            environment: environment)
        end
      end

      it_behaves_like 'removing cluster'

      it 'stops removing cluster' do
        expect_any_instance_of(Clusters::Cluster).to receive(:stop_removing!)

        subject
      end

      it 'deletes namespaces' do
        expect { subject }.to change { Clusters::KubernetesNamespace.count }.by(-2)
      end

      it 'deletes cluster' do
        expect { subject }.to change { Clusters::Cluster.count }.by(-1)
      end
    end

    context 'when cluster has uninstallable applications' do
      context 'has applications with dependencies' do
        before do
          expect(described_class)
            .to receive(:perform_in)
            .with(20.seconds, cluster.id, 1)
        end

        after do
          subject
        end

        let!(:helm) { create(:clusters_applications_helm, :installed, cluster: cluster) }
        let!(:ingress) { create(:clusters_applications_ingress, :installed, cluster: cluster) }
        let!(:cert_manager) { create(:clusters_applications_cert_manager, :installed, cluster: cluster) }
        let!(:jupyter) { create(:clusters_applications_jupyter, :installed, cluster: cluster) }

        it_behaves_like 'removing cluster'

        it 'only uninstalls apps that are not dependencies for other installed apps' do
          expect(Clusters::Applications::UninstallService)
            .not_to receive(:new).with(helm)

          expect(Clusters::Applications::UninstallService)
            .not_to receive(:new).with(ingress)

          expect(Clusters::Applications::UninstallService)
            .to receive(:new).with(cert_manager)
            .and_call_original

          expect(Clusters::Applications::UninstallService)
            .to receive(:new).with(jupyter)
            .and_call_original
        end
      end
    end

    context 'when applications are still uninstalling/scheduled' do
      after do
        subject
      end

      let!(:helm) { create(:clusters_applications_helm, :installed, cluster: cluster) }
      let!(:ingress) { create(:clusters_applications_ingress, :scheduled, cluster: cluster) }
      let!(:runner) { create(:clusters_applications_runner, :uninstalling, cluster: cluster) }

      it 'reschedules the worker to proceed the uninstallation later' do
        expect(Clusters::Applications::UninstallService)
          .not_to receive(:new)

        expect(described_class)
          .to receive(:perform_in)
          .with(20.seconds, cluster.id, 1)
      end
    end

    context 'when exceeded the execution limit' do
      subject { described_class.new.perform(cluster.id, described_class::EXECUTION_LIMIT) }

      it 'stops removing cluster' do
        expect_any_instance_of(Clusters::Cluster).to receive(:stop_removing!)

        subject
      end

      it 'logs the error' do
        expect_any_instance_of(Gitlab::Kubernetes::Logger).to receive(:error).with(
          hash_including(
            exception: 'ClusterRemoveWorker::ExceededExecutionLimitError',
            status_code: nil,
            namespace: nil,
            class_name: described_class.name,
            event: :failed_to_remove_cluster_and_resources,
            message: 'retried too many times'
          )
        )

        subject
      end
    end
  end
end
