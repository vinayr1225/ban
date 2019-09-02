# frozen_string_literal: true

# This worker asynchronously uninstalls all the Clusters::Applications. It
# reschedules itself to check if those applications have already succeded or
# failed. If succeded, it tries to uninstall other applications that could be
# dependending on the first ones. Finally, if some applications could not be
# uninstalled after EXECUTION_LIMIT amount of executions, this worker gives
# up on trying.

class ClusterRemoveWorker
  include ApplicationWorker
  include ClusterQueue

  # The amount of times this job is called for the same cluster, while
  # waiting for all the applications to finish uninstalling.
  #
  # This limit should be at least higher than the number of uninstall
  # dependencies of an applications.
  EXECUTION_LIMIT = 5
  EXECUTION_INTERVAL = 10.seconds

  def perform(cluster_id, execution_count = 0)
    @execution_count = execution_count
    # TODO: Log error and notify user that the cluster uninstall failed and
    # needs to be manually retried.
    #
    # https://gitlab.com/gitlab-org/gitlab-ce/issues/66729
    return if exceeded_execution_limit?

    @cluster = Clusters::Cluster.preload_applications.find_by_id(cluster_id)

    return unless @cluster

    uninstallable_apps = @cluster.preloaded_applications.select(&:can_uninstall?)

    if uninstallable_apps.present?
      uninstallable_apps.each { |app| uninstall_app_async(app) }

      return schedule_next_execution
    end

    # This is necessary in case the only applications left are stil in a
    # not uninstallable state (scheduled|uninstalling). So we give more time
    # for them to finish their uninstallation.
    return schedule_next_execution if @cluster.preloaded_applications.present?

    # delete_roles_and_namespaces

    @cluster.destroy
  end

  private

  def exceeded_execution_limit?
    EXECUTION_LIMIT == @execution_count
  end

  def schedule_next_execution
    @execution_count += 1

    ClusterRemoveWorker.perform_in(EXECUTION_INTERVAL, @cluster.id, @execution_count)
  end

  def uninstall_app_async(application)
    application.make_scheduled!

    Clusters::Applications::UninstallService.new(application).execute
  end

  # def delete_roles_and_namespaces
  # end
end
