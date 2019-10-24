# frozen_string_literal: true

module Gitlab
  module Graphql
    module Loaders
      class BatchEpicIssuesLoader
        def initialize(model_id, user)
          @model_id = model_id
          @user = user
        end

        # rubocop: disable CodeReuse/ActiveRecord
        def find
          BatchLoader::GraphQL.for(@model_id).batch(default_value: nil) do |ids, loader|
            results = ::Issue.select('issues.*, epic_issues.epic_id as epic_id')
              .joins(:epic_issue)
              .where("epic_issues.epic_id": ids)

            results.each do |record|
              loader.call(record.epic_id) do |memo|
                memo ||= Gitlab::Graphql::Authorize::AuthorizeArray.new(filter_authorized)
                memo << record
              end
            end
          end
        end

        def filter_authorized
          proc do |issues|
            Ability.issues_readable_by_user(issues, @user)
          end
        end
        # rubocop: enable CodeReuse/ActiveRecord
      end
    end
  end
end
