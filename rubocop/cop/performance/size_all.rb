# frozen_string_literal: true
module RuboCop
  module Cop
    module Performance

      # This is a modified version of the cop Performance/Size
      # https://github.com/rubocop-hq/rubocop/blob/master/lib/rubocop/cop/performance/size.rb

      # The original copy only was applied when the node receiver
      # was an array or a hash. Nevertheless, it brings some
      # benefits to apply the same behavior to ActiveRecord relations
      # https://github.com/rubocop-hq/rails-style-guide#size-over-count-or-length

      # In this cop, we enforce the use of size vs count unless count has a block
      class SizeAll < Cop
        MSG = 'Use `size` instead of `count`.'.freeze

        def on_send(node)
          return unless eligible_node?(node)

          add_offense(node, location: :selector)
        end

        def autocorrect(node)
          ->(corrector) { corrector.replace(node.loc.selector, 'size') }
        end

        private

        def eligible_node?(node)
          return false unless node.method?(:count) && !node.arguments?

          node.receiver && !allowed_parent?(node.parent)
        end

        def allowed_parent?(node)
          node && node.block_type?
        end
      end
    end
  end
end
