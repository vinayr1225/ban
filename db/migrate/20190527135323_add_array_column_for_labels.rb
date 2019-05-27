class AddArrayColumnForLabels < ActiveRecord::Migration[5.1]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    add_column :issues, :label_titles, :text, array: true
    add_column :merge_requests, :label_titles, :text, array: true
  end
end
