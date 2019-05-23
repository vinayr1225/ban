git add $0
git stash --keep-index --include-untracked

for source_file in $(find spec/javascripts -type f)
do
  dest_file=$(echo $source_file | sed "s|spec/javascripts|spec/frontend|")  
  dest_dir=$(dirname $dest_file)

  # Move it!
  mkdir -p $dest_dir
  mv $source_file $dest_file

  # Jest it!
  sed -i "s/^.*jasmine.clock.*.install.*$/ /g" $dest_file
  sed -i "s/^.*jasmine.clock.*.uninstall.*$/ /g" $dest_file
done

yarn run jest --bail
