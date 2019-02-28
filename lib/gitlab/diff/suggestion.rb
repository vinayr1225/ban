# frozen_string_literal: true

module Gitlab
  module Diff
    class Suggestion
      def initialize(text, lines_above, lines_below, project:, position:)
        @text = text
        @lines_above = lines_above
        @lines_below = lines_below
        @project = project
        @position = position
      end

      def to_hash
        {
          from_content: from_content,
          to_content: to_content
        }
      end

      private

      def from_line
        @position.new_line - @lines_above
      end

      def to_line
        @position.new_line + @lines_below
      end

      def to_content
        # The parsed suggestion doesn't have information about the correct
        # ending characters (we may have a line break, or not), so we take
        # this information from the last line being changed (last
        # characters).
        endline_chars = line_break_chars(from_content.lines.last)
        "#{@text}#{endline_chars}"
      end

      def from_content
        diff_file.new_blob_lines_between(from_line, to_line).join
      end

      def line_break_chars(line)
        match = /\r\n|\r|\n/.match(line)
        match[0] if match
      end

      # TODO: optimize?
      def diff_file
        @diff_file ||= @position.diff_file(@project.repository)
      end
    end
  end
end
