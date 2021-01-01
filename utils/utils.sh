#!/bin/bash
script_files=(help.sh general.sh)

for file in ${script_files[@]}; do
	source "$bambo_dir/utils/$file"
done
