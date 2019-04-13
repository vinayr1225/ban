# frozen_string_literal: true

module HamlLint
  # Checks for unwrapped text nodes.
  # Useful for i18n helper methods.
  #
  # Fail:  %tag Some text
  # Pass:  %tag= _('Some text')
  class Linter::UnwrappedPlainNode < Linter
    include LinterRegistry

    MESSAGE = '`= "..."` should be rewritten as `...`'.freeze

    def visit_plain(node)
      record_lint(node, MESSAGE)
    end
  end
end
