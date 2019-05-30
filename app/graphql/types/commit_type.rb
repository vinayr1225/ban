# frozen_string_literal: true
module Types
  class CommitType < BaseObject
    graphql_name 'Commit'

    field :id, GraphQL::ID_TYPE, null: false
    field :message, GraphQL::STRING_TYPE, null: false

    field :authored_date, Types::TimeType, null: false
    field :author_name, GraphQL::STRING_TYPE, null: false
    field :author_email, GraphQL::STRING_TYPE, null: false

    field :committed_date, Types::TimeType, null: false
    field :committer_name, GraphQL::STRING_TYPE, null: false
    field :committer_email, GraphQL::STRING_TYPE, null: false
  end
end
