# frozen_string_literal: true

module Gitlab
  module Graphql
    module Connections
      class FilterableArrayConnection < GraphQL::Relay::ArrayConnection
        def paged_nodes
          @authorized_nodes ||= begin
                                  callback = nodes.filter_callback
                                  callback.call(super)
                                end
        end
      end
    end
  end
end
