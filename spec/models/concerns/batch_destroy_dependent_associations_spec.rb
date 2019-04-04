# frozen_string_literal: true

require 'spec_helper'

describe BatchDestroyDependentAssociations do
  class TestProject < ActiveRecord::Base
    self.table_name = 'projects'

    has_many :builds, dependent: :destroy
    has_many :notification_settings, as: :source, dependent: :delete_all
    has_many :pages_domains
    has_many :todos

    include BatchDestroyDependentAssociations
  end

  describe '#dependent_associations_to_destroy' do
    set(:project) { TestProject.new }

    it 'returns the right associations' do
      expect(project.dependent_associations_to_destroy.map(&:name)).to match_array([:builds])
    end
  end

  describe '#destroy_dependent_associations_in_batches' do
    set(:project) { create(:project) }
    set(:build) { create(:ci_build, project: project) }
    set(:notification_setting) { create(:notification_setting, project: project) }
    let!(:todos) { create(:todo, project: project) }

    it 'destroys multiple builds' do
      create(:ci_build, project: project)

      expect(Ci::Build.size).to eq(2)

      project.destroy_dependent_associations_in_batches

      expect(Ci::Build.size).to eq(0)
    end

    it 'destroys builds in batches' do
      expect(project).to receive_message_chain(:builds, :find_each).and_yield(build)
      expect(build).to receive(:destroy).and_call_original

      project.destroy_dependent_associations_in_batches

      expect(Ci::Build.size).to eq(0)
      expect(Todo.size).to eq(1)
      expect(User.size).to be > 0
      expect(NotificationSetting.size).to eq(User.size)
    end

    it 'excludes associations' do
      project.destroy_dependent_associations_in_batches(exclude: [:builds])

      expect(Ci::Build.size).to eq(1)
      expect(Todo.size).to eq(1)
      expect(User.size).to be > 0
      expect(NotificationSetting.size).to eq(User.size)
    end
  end
end
