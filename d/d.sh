#!/bin/bash
script_files=(general.sh compose.sh)

# Move to closest docker-compose
workdir=$(orb utils upfind docker-compose.yml)

if [[ -n  "$workdir" ]]; then
	cd "$workdir"

	# Parse .env
	if [ -f '.env' ]; then
		$(orb utils parseenv .env)
	else
		echo 'No .env file!'
	fi

	# Project specific additions
	if [ -f '_docker/d.sh' ]; then
		script_files+=($(realpath --relative-to="$script_dir" "_docker/d.sh"))
	fi

# --help and general functions dont require docker-compose.yml
elif [["$function_name" != "--help" ]] && ! $(orb utils hasfunction $function_name $script_dir/general.sh); then
	echo 'No docker-compose.yml found!'
	exit 1
fi

# Source functions
for file in ${script_files[@]}; do
	source "$script_dir/$file"
done


