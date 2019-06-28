# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Kubernetes::ClusterRole do
  let(:cluster_role) { described_class.new(name, labels, rules) }

  let(:name) { 'example-cluster-role' }
  let(:labels) { { 'rbac.authorization.k8s.io/aggregate-to-edit' => 'true' } }
  let(:rules) do
    [{
      apiGroups: %w(serving.knative.dev),
      resources: %w(configurations configurationgenerations routes revisions revisionuids autoscalers services),
      verbs: %w(get list create update delete patch watch)
    }]
  end

  describe '#generate' do
    let(:resource) do
      ::Kubeclient::Resource.new(
        metadata: { name: name, labels: labels },
        rules: rules
      )
    end

    subject { cluster_role.generate }

    it { is_expected.to eq(resource) }
  end
end
