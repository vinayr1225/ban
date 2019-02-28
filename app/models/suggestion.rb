# frozen_string_literal: true

class Suggestion < ApplicationRecord
  belongs_to :note, inverse_of: :suggestions
  validates :note, presence: true
  validates :commit_id, presence: true, if: :applied?

  delegate :original_position, :position, :noteable, to: :note

  def project
    noteable.source_project
  end

  def branch
    noteable.source_branch
  end

  def file_path
    position.file_path
  end

  def from_line
    position.new_line - lines_above
  end

  def to_line
    position.new_line + lines_below
  end

  # TODO: persist it
  def lines_above
    0
  end

  def lines_below
    0
  end

  # TODO: Is that even needed? I think we can remove it.
  def from_original_line
    original_position.new_line
  end
  alias_method :to_original_line, :from_original_line

  # `from_line_index` and `to_line_index` represents diff/blob line numbers in
  # index-like way (N-1).
  def from_line_index
    from_line - 1
  end
  alias_method :to_line_index, :from_line_index

  def appliable?
    return false unless note.supports_suggestion?

    !applied? &&
      noteable.opened? &&
      different_content? &&
      note.active?
  end

  private

  def different_content?
    from_content != to_content
  end
end
