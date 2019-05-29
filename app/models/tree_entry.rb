# frozen_string_literal: true

class TreeEntry < SimpleDelegator
  class << self
    def decorate(entries, repository)
      entries.map do |entry|
        if entry.is_a?(TreeEntry)
          entry
        else
          self.new(entry, repository)
        end
      end
    end
  end

  attr_accessor :repository, :raw_entry

  def initialize(raw_entry, repository)
    @repository = repository

    super(raw_entry)
  end
end
