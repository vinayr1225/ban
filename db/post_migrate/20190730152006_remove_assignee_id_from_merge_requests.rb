# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class RemoveAssigneeIdFromMergeRequests < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    remove_reference :merge_requests, :assignee, index: true, foreign_key: { to_table: :users }
  end
end
