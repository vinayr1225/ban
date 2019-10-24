# frozen_string_literal: true

module Gitlab
  module Graphql
    module Connections
      class AuthorizeArrayConnection < GraphQL::Relay::ArrayConnection
        def paged_nodes
          @authorized_nodes ||= begin
                                  callback = nodes.callback
                                  nodes = super
                                  callback.call(nodes)
                                end
        end
      end
    end
  end
end
