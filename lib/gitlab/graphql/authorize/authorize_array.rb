# frozen_string_literal: true

module Gitlab
  module Graphql
    module Authorize
      class AuthorizeArray < Array
        attr_reader :callback

        def initialize(callback)
          @callback = callback
        end
      end
    end
  end
end
