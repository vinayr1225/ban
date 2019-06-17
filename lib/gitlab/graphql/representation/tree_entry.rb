# frozen_string_literal: true

module Gitlab
  module Graphql
    module Representation
      class TreeEntry < SimpleDelegator
        class << self
          def decorate(entries, tree)
            return if entries.nil?

            entries.map do |entry|
              if entry.is_a?(TreeEntry)
                entry
              else
                self.new(entry, tree)
              end
            end
          end
        end

        attr_accessor :tree
        delegate :repository, to: :tree

        def initialize(raw_entry, tree)
          @tree = tree

          super(raw_entry)
        end
      end
    end
  end
end
