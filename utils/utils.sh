#!/bin/bash
script_files=(
	arguments.sh
	help.sh
	general.sh
	text.sh
)

for file in ${script_files[@]}; do
	source "$orb_dir/utils/$file"
done
