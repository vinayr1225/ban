# frozen_string_literal: true

module Gitlab
  module Graphql
    module Connections
      def self.use(_schema)
        GraphQL::Relay::BaseConnection.register_connection_implementation(
          ActiveRecord::Relation,
          Gitlab::Graphql::Connections::KeysetConnection
        )
        GraphQL::Relay::BaseConnection.register_connection_implementation(
          Gitlab::Graphql::Authorize::AuthorizeArray,
          Gitlab::Graphql::Connections::AuthorizeArrayConnection
        )
      end
    end
  end
end
