# frozen_string_literal: true

module Resolvers
  class LastCommitResolver < BaseResolver
    def resolve
      Gitlab::GitalyClient.allow_n_plus_1_calls do
        Gitlab::Git::Commit.last_for_path(object.repository, object.commit_id, object.path)
      end
    end
  end
end
