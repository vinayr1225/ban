# frozen_string_literal: true

# A collection of events to display in an event list.
#
# An EventCollection is meant to be used for displaying events to a user (e.g.
# in a controller), it's not suitable for building queries that are used for
# building other queries.
class EventCollection
  include Gitlab::Utils::StrongMemoize

  # To prevent users from putting too much pressure on the database by cycling
  # through thousands of events we put a limit on the number of pages.
  MAX_PAGE = 10

  # projects - An ActiveRecord::Relation object that returns the projects for
  #            which to retrieve events.
  # filter - An EventFilter instance to use for filtering events.
  def initialize(projects, limit: 20, offset: 0, filter: nil, groups: nil)
    @projects = projects
    @limit = limit
    @offset = offset
    @filter = filter
    @groups = groups
  end

  # Returns an Array containing the events.
  def to_a
    return [] if current_page > MAX_PAGE

    relation_with_join_lateral.with_associations.to_a
  end

  private

  # This relation is built using JOIN LATERAL, producing faster queries than a
  # regular LIMIT + OFFSET approach.
  def relation_with_join_lateral
    # The outer query does not need to re-apply the filters since the JOIN
    # LATERAL body already takes care of this.
    outer = base_relation
      .from("(#{parents_for_lateral}) parents_for_lateral")
      .joins("JOIN LATERAL (#{join_lateral}) AS #{Event.table_name} ON true")

    paginate_events(outer)
  end

  def join_lateral
    condition = if groups.present?
                  'events.project_id = parents_for_lateral.project_id OR events.group_id = parents_for_lateral.group_id'
                else
                  'events.project_id = parents_for_lateral.project_id'
                end

    filtered_events
      .limit(limit_for_join_lateral)
      .where(condition)
      .to_sql
  end

  def parents_for_lateral
    if groups.present?
      members = [
        groups.select('NULL as project_id, id as group_id'),
        projects.select('id as project_id, NULL as group_id')
      ]

      Gitlab::SQL::Union.new(members).to_sql # rubocop: disable Gitlab/Union
    else
      projects.select('id as project_id').to_sql
    end
  end

  def filtered_events
    @filter ? @filter.apply_filter(base_relation) : base_relation
  end

  def paginate_events(events)
    events.limit(@limit).offset(@offset)
  end

  def base_relation
    # We want to have absolute control over the event queries being built, thus
    # we're explicitly opting out of any default scopes that may be set.
    Event.unscoped.recent
  end

  def limit_for_join_lateral
    # Applying the OFFSET on the inside of a JOIN LATERAL leads to incorrect
    # results. To work around this we need to increase the inner limit for every
    # page.
    #
    # This means that on page 1 we use LIMIT 20, and an outer OFFSET of 0. On
    # page 2 we use LIMIT 40 and an outer OFFSET of 20.
    @limit + @offset
  end

  def current_page
    (@offset / @limit) + 1
  end

  def projects
    @projects.except(:order)
  end

  def groups
    strong_memoize(:groups) do
      groups.except(:order) if @groups && Event.has_group_events?
    end
  end
end
