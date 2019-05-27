class FillArrayColumnForLabels < ActiveRecord::Migration[5.1]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    update!('issues')
    update!('merge_requests')
  end

  private

  def update!(table)
    execute <<-SQL
      UPDATE #{table}
      SET label_titles = subquery.label_titles
      FROM
        (
          SELECT #{table}.id AS id, array_agg(labels.title) AS label_titles
          FROM #{table}
          LEFT JOIN label_links ON target_id = #{table}.id AND label_links.target_type = 'Issue'
          LEFT JOIN labels ON label_id = labels.id
          GROUP BY #{table}.id
        ) AS subquery
      WHERE #{table}.id = subquery.id;
    SQL
  end
end
