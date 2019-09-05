# frozen_string_literal: true

class CommitWithPipelinePresenter < CommitPresenter
  def status_for(ref)
    can?(current_user, :read_commit_status, commit.project) && commit.latest_pipeline(ref)&.detailed_status(current_user)
  end

  def any_pipelines?
    can?(current_user, :read_pipeline, commit.project) && commit.pipelines.any?
  end
end
