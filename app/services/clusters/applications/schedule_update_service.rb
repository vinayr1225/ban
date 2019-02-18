# frozen_string_literal: true

module Clusters
  module Applications
    class ScheduleUpdateService
      attr_reader :application

      def initialize(application)
        @application = application
      end

      def execute
        schedule_update
      end

      private

      def schedule_update
        application.make_scheduled!

        ClusterUpdateAppWorker.perform_async(application.name, application.id)
      end
    end
  end
end
