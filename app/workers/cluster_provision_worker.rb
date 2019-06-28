# frozen_string_literal: true

class ClusterProvisionWorker
  include ApplicationWorker
  include ClusterQueue

  def perform(cluster_id)
    Clusters::Cluster.find_by_id(cluster_id).try do |cluster|
      if cluster.gcp?
        cluster.provider.try do |provider|
          Clusters::Gcp::ProvisionService.new.execute(provider)
        end
      elsif cluster.user?
        if cluster.platform_kubernetes_rbac? && cluster.managed?
          create_or_update_aggregate_to_edit_role(cluster)
        end
      end
    end
  end

  private

  def create_or_update_aggregate_to_edit_role(cluster)
    name = 'gitlab-knative-serving-only-role'
    labels = { 'rbac.authorization.k8s.io/aggregate-to-edit' => 'true' }
    rules = [{
      apiGroups: %w(serving.knative.dev),
      resources: %w(configurations configurationgenerations routes revisions revisionuids autoscalers services),
      verbs: %w(get list create update delete patch watch)
    }]

    cluster_role = Gitlab::Kubernetes::ClusterRole.new(name, labels, rules)

    # update_cluster_role actually behaves like a "create or update" method
    cluster.kubeclient.update_cluster_role(cluster_role.generate)
  end
end
