# frozen_string_literal: true

module Banzai
  module SuggestionsParser
    # Matches for instance "-1", "+1" or "-1+2".
    SUGGESTION_CONTEXT = /^(\-(?<above>\d+))?(\+(?<below>\d+))?$/.freeze

    class << self
      # Returns the content of each suggestion code block.
      #
      def parse(text, project:, position:)
        html = Banzai.render(text, project: nil, no_original_data: true)
        doc = Nokogiri::HTML(html)

        doc.search('pre.suggestion').map do |node|
          lang_param = node['lang-params']

          lines_above, lines_below = nil

          if lang_param && suggestion_params = fetch_suggestion_params(lang_param)
            lines_above, lines_below =
              suggestion_params[:above],
              suggestion_params[:below]
          end

          # TODO: Return array here and extract building logic with project and
          # position to a builder or something.
          Gitlab::Diff::Suggestion.new(node.text,
                                       lines_above.to_i,
                                       lines_below.to_i,
                                       project: project,
                                       position: position)
        end
      end

      private

      def fetch_suggestion_params(lang_param)
        lang_param.match(SUGGESTION_CONTEXT)
      end
    end
  end
end
