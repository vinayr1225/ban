# frozen_string_literal: true

# Generated HTML is transformed back to GFM by app/assets/javascripts/behaviors/markdown/nodes/code_block.js
module Banzai
  module Filter
    class SuggestionFilter < HTML::Pipeline::Filter
      # Matches for instance "-1", "+1" or "-1+2".
      SUGGESTION_CONTEXT = /^(\-(?<above>\d+))?(\+(?<below>\d+))?$/.freeze

      # Class used for tagging elements that should be rendered
      TAG_CLASS = 'js-render-suggestion'.freeze

      def call
        return doc unless suggestions_filter_enabled?

        # TODO:
        # - Fetch parent beforehand
        doc.search('pre.suggestion > code').each do |node|
          node.add_class(TAG_CLASS)

          pre = node.parent
          lang_param = pre['lang-params']

          next node unless suggestion_context?(lang_param)

          # TODO: Move all this logic to the parser and return JSON to FE
          # instead. String doesn't make much sense.
          node.set_attribute('data-lines-above', -lines_above(lang_param).to_i)
          node.set_attribute('data-lines-below', lines_below(lang_param).to_i)
        end

        doc
      end

      private

      def suggestion_context?(lang_param)
        lang_param.present? && fetch_suggestion_context(lang_param)
      end

      def lines_above(lang_param)
        fetch_suggestion_context(lang_param)[:above]
      end

      def lines_below(lang_param)
        fetch_suggestion_context(lang_param)[:below]
      end

      def fetch_suggestion_context(lang_param)
        # TODO:
        # - Memoize it?
        lang_param.match(SUGGESTION_CONTEXT)
      end

      def suggestions_filter_enabled?
        context[:suggestions_filter_enabled]
      end
    end
  end
end
