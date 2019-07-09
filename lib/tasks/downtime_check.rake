desc 'Checks if migrations in a branch require downtime'
task :downtime_check, [:source_sha, :target_sha] => :environment do |_, args|
  repo = if defined?(Gitlab::License)
           'gitlab-ee'
         else
           'gitlab-ce'
         end

  `git fetch https://gitlab.com/gitlab-org/#{repo}.git --depth 1`

  Rake::Task['gitlab:db:downtime_check'].invoke((args[:source_sha] || 'FETCH_HEAD'), args[:target_sha])
end
