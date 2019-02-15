# frozen_string_literal: true

class BackfillPrometheusQueries < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    execute <<~SQL
      INSERT INTO prometheus_queries (prometheus_metric_id, identifier, query, legend, unit, created_at, updated_at)
      SELECT id, identifier, query, legend, unit, created_at, updated_at
      FROM prometheus_metrics;
    SQL
  end

  def down
    execute <<-SQL
      DELETE FROM prometheus_queries;
    SQL
  end
end
