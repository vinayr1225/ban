# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class ScheduleProjectAnyApprovalRuleMigration < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  BATCH_SIZE = 25_000
  MIGRATION = 'PopulateAnyApprovalRuleForProjects'
  DELAY_INTERVAL = 8.minutes.to_i

  disable_ddl_transaction!

  def up
    return unless Gitlab.ee?

    say "Scheduling `#{MIGRATION}` jobs"

    # We currently have ~10_300_000 project records on GitLab.com.
    # This means it'll schedule ~400 jobs (25k projects each) with a 8 minutes gap,
    # so this should take ~53 hours (~2 days) for all background migrations to complete.
    #
    # The approximate expected number of affected rows is: 18k

    queue_background_migration_jobs_by_range_at_intervals(Project, MIGRATION, DELAY_INTERVAL, batch_size: BATCH_SIZE)
  end

  def down
    # no-op
  end
end
