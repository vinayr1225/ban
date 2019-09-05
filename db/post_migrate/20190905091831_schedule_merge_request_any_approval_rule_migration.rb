# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class ScheduleMergeRequestAnyApprovalRuleMigration < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  BATCH_SIZE = 25_000
  MIGRATION = 'PopulateAnyApprovalRuleForMergeRequests'
  DELAY_INTERVAL = 8.minutes.to_i

  disable_ddl_transaction!

  def up
    return unless Gitlab.ee?

    say "Scheduling `#{MIGRATION}` jobs"

    # We currently have ~29_300_000 merge request records on GitLab.com.
    # This means it'll schedule ~1160 jobs (25k merge requests each) with a 8 minutes gap,
    # so this should take ~156 hours (~6.5 days) for all background migrations to complete.
    #
    # The approximate expected number of affected rows is: 190k

    queue_background_migration_jobs_by_range_at_intervals(MergeRequest, MIGRATION, DELAY_INTERVAL, batch_size: BATCH_SIZE)
  end

  def down
    # no-op
  end
end
