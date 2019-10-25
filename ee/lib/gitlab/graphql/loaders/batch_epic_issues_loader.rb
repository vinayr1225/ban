# frozen_string_literal: true

module Gitlab
  module Graphql
    module Loaders
      class BatchEpicIssuesLoader
        def initialize(model_id, user)
          @model_id = model_id
          @user = user
        end

        def find
          BatchLoader::GraphQL.for(@model_id).batch(default_value: nil) do |ids, loader|
            issues = ::Epic.related_issues(ids: ids, preload: { project: :namespace })

            issues.each do |issue|
              loader.call(issue.epic_id) do |memo|
                memo ||= Gitlab::Graphql::FilterableArray.new(filter_authorized)
                memo << issue
              end
            end
          end
        end

        def filter_authorized
          proc do |issues|
            Ability.issues_readable_by_user(issues, @user)
          end
        end
      end
    end
  end
end
