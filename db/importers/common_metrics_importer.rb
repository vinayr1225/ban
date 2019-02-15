# frozen_string_literal: true

module Importers
  class PrometheusMetric < ActiveRecord::Base
    enum group: {
      # built-in groups
      nginx_ingress_vts: -1,
      ha_proxy: -2,
      aws_elb: -3,
      nginx: -4,
      kubernetes: -5,
      nginx_ingress: -6,

      # custom groups
      business: 0,
      response: 1,
      system: 2
    }

    has_many :prometheus_queries
    scope :common, -> { where(common: true) }

    GROUP_TITLES = {
      business: _('Business metrics (Custom)'),
      response: _('Response metrics (Custom)'),
      system: _('System metrics (Custom)'),
      nginx_ingress_vts: _('Response metrics (NGINX Ingress VTS)'),
      nginx_ingress: _('Response metrics (NGINX Ingress)'),
      ha_proxy: _('Response metrics (HA Proxy)'),
      aws_elb: _('Response metrics (AWS ELB)'),
      nginx: _('Response metrics (NGINX)'),
      kubernetes: _('System metrics (Kubernetes)')
    }.freeze
  end

  class PrometheusQuery < ActiveRecord::Base
    belongs_to :prometheus_metric
  end

  class CommonMetricsImporter
    MissingQueryId = Class.new(StandardError)

    attr_reader :content

    def initialize(filename = 'common_metrics.yml')
      @content = YAML.load_file(Rails.root.join('config', 'prometheus', filename))
    end

    def execute
      PrometheusMetric.reset_column_information
      PrometheusQuery.reset_column_information

      process_content do |metric_attributes|
        find_or_build_metric!(metric_attributes)
          .update!(**metric_attributes)
      end
    end

    private

    def process_content(&blk)
      content.map do |group|
        process_group(group, &blk)
      end
    end

    def process_group(group, &blk)
      metric_attributes = {
        group: find_group_title_key(group['group'])
      }

      group['metrics'].map do |metric|
        process_metric(metric, metric_attributes, &blk)
      end
    end

    def process_metric(metric, metric_attributes, &blk)
      queries = metric['queries'].map do |query|
        process_query(query)
      end

      yield metric_attributes.merge(
        title: metric['title'],
        y_label: metric['y_label'],
        prometheus_queries: queries
      )
    end

    def process_query(query)
      prometheus_query = find_or_build_query!(query['id'])
      prometheus_query.assign_attributes(
        legend: query['label'],
        query: query['query_range'],
        unit: query['unit']
      )
      prometheus_query
    end

    def find_or_build_query!(id)
      raise MissingQueryId unless id

      PrometheusQuery.find_by(identifier: id) ||
        PrometheusQuery.new(identifier: id)
    end

    def find_or_build_metric!(metric_attributes)
      target_attributes = metric_attributes.slice(:group, :title, :y_label)

      PrometheusMetric.common.find_by(target_attributes) ||
        PrometheusMetric.new(common: true)
    end

    def find_group_title_key(title)
      PrometheusMetric.groups[find_group_title(title)]
    end

    def find_group_title(title)
      PrometheusMetric::GROUP_TITLES.invert[title]
    end
  end
end
