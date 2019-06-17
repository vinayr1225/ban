# frozen_string_literal: true

module Resolvers
  class LastCommitResolver < BaseResolver
    def resolve
      batched_commit
    end

    private

    def batched_commit
      BatchLoader.for(object.path).batch(key: object.tree) do |paths, loader, args|
        tree = args[:key]
        commits = tree.repository.list_last_commits_for_tree(tree.sha, tree.path, limit: 2 ** 31 - 1)

        paths.each do |path|
          commit = commits[path]
          loader.call(path, commit) if commit
        end
      end
    end
  end
end
