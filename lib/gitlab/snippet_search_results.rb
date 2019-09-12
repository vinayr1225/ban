# frozen_string_literal: true

module Gitlab
  class SnippetSearchResults < SearchResults
    include SnippetsHelper
    include Gitlab::Utils::StrongMemoize

    attr_reader :limit_snippets

    def initialize(limit_snippets, query)
      @limit_snippets = limit_snippets
      @query = query
    end

    def objects(scope, page = nil)
      case scope
      when 'snippet_titles'
        snippet_titles.page(page).per(per_page)
      when 'snippet_blobs'
        snippet_blobs.page(page).per(per_page)
      else
        super(scope, nil, false)
      end
    end

    def formatted_count(scope)
      case scope
      when 'snippet_titles'
        formatted_limited_count(limited_snippet_titles_count)
      when 'snippet_blobs'
        formatted_limited_count(limited_snippet_blobs_count)
      else
        super
      end
    end

    def limited_snippet_titles_count
      strong_memoize(:limited_snippet_titles_count) do
        limited_count(snippet_titles)
      end
    end

    def limited_snippet_blobs_count
      strong_memoize(:limited_snippet_blobs_count) do
        limited_count(snippet_blobs)
      end
    end

    private

    # rubocop: disable CodeReuse/ActiveRecord
    def snippet_titles
      limit_snippets.search(query).reorder('updated_at DESC').includes(:author)
    end
    # rubocop: enable CodeReuse/ActiveRecord

    # rubocop: disable CodeReuse/ActiveRecord
    def snippet_blobs
      limit_snippets.search_code(query).reorder('updated_at DESC').includes(:author)
    end
    # rubocop: enable CodeReuse/ActiveRecord

    def default_scope
      'snippet_blobs'
    end
  end
end
