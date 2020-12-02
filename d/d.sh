#!/bin/bash
# Move to closest docker-compose
workdir=$($utils upfind docker-compose.yml)
if [ -z  $workdir ]; then
	if ! $($utils hasfunction $function_name $script_dir/general.sh); then
			echo 'No docker-compose.yml found!'
			exit 1
	fi
else
	cd $workdir
fi

# Parse .env
if [ -f '.env' ]; then
	$($utils parseenv .env)
else
	echo 'No .env file!'
fi

# Source functions
source $script_dir/general.sh
source $script_dir/compose.sh

# Project specific additions
if [ -f '_docker/d.sh' ]; then
	source _docker/d.sh
fi
