# frozen_string_literal: true

module Types
  class MutationType < BaseObject
    include Gitlab::Graphql::MountMutation

    graphql_name "Mutation"

    mount_mutation Mutations::AwardEmojis::Add
    mount_mutation Mutations::AwardEmojis::Remove
    mount_mutation Mutations::AwardEmojis::Toggle
    mount_mutation Mutations::MergeRequests::SetWip, calls_gitaly: true
    mount_mutation Mutations::Notes::Create::Note
    mount_mutation Mutations::Notes::Create::DiffNote
    mount_mutation Mutations::Notes::Create::ImageDiffNote
    mount_mutation Mutations::Notes::Update
    mount_mutation Mutations::Notes::Destroy
  end
end
