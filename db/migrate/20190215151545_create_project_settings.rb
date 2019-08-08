# frozen_string_literal: true

class CreateProjectSettings < ActiveRecord::Migration[5.0]
  DOWNTIME = false

  def change
    create_table :project_settings do |t|
      t.references :project,
                   null: false,
                   index: { unique: true },
                   foreign_key: { on_delete: :cascade }

      t.boolean :forking_enabled,
                default: true,
                null: false

      t.timestamps_with_timezone null: false
    end
  end
end
