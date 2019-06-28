# frozen_string_literal: true

module Gitlab
  module Kubernetes
    class ClusterRole
      attr_reader :name, :labels, :rules

      def initialize(name, labels, rules)
        @name = name
        @labels = labels
        @rules = rules
      end

      def generate
        ::Kubeclient::Resource.new(
          metadata: { name: name, labels: labels },
          rules: rules
        )
      end
    end
  end
end
