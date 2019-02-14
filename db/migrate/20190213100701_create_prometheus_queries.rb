# frozen_string_literal: true

class CreatePrometheusQueries < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    create_table :prometheus_queries do |t|
      t.references :prometheus_metric, null: false, index: true, foreign_key: { on_delete: :cascade }
      t.string :identifier
      t.string :query, null: false
      t.string :unit, null: false
      t.string :legend
      t.timestamps_with_timezone null: false
    end
  end
end
