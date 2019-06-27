# frozen_string_literal: true

module Gitlab
  module CycleAnalytics
    class ScatterplotChartDataFetcher < BaseStage
      def initialize(stage)
        @stage = stage
      end

      def fetch
        ActiveRecord::Base.connection.execute(build_query.to_sql)
      end

      private
      
      attr_reader :stage

      def build_query
        duration = subtract_datetimes_diff(stage.start_time_attrs, stage.end_time_attrs)
        days_took = Arel::Nodes::NamedFunction.new("EXTRACT", [Arel::Nodes::NamedFunction.new("DAY FROM", [duration])])

        query = stage.stage_query(stage.send(:projects).map(&:id))
        query.projections = []
        query.project(days_took.as('days_took'))
        query.project(
          Arel::Nodes::NamedFunction.new("DATE", [
            Arel::Nodes::NamedFunction.new("COALESCE", Array.wrap(stage.end_time_attrs))
          ]).as('finished_at')
        )
        query.where(duration.gteq(zero_interval))
        query
      end
    end
  end
end
