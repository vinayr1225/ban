# frozen_string_literal: true

module Resolvers
  class EpicIssuesResolver < BaseResolver
    type Types::EpicIssueType, null: true

    alias_method :epic, :object

    def resolve(**args)
      Gitlab::Graphql::Loaders::BatchEpicIssuesLoader.new(epic.id, context[:current_user]).find
    end
  end
end
