# frozen_string_literal: true

# This module handles backward compatibility for import/export of Merge Requests after
# multiple assignees feature was introduced. Also, it handles the scenarios where
# the #26496 background migration hasn't finished yet.
# Ideally, most of this code should be removed at #59457.
module DeprecatedAssignee
  extend ActiveSupport::Concern

  def assignee_id=(id)
    self.assignee_ids = Array(id)
  end

  def assignee=(user)
    self.assignees = Array(user)
  end

  def assignee
    assignees.first
  end

  def assignee_id
    assignee_ids.first
  end
end
