#!/bin/bash
# Move to closest docker-compose
workdir=$($utils upfind docker-compose.yml)
if [ -z  $workdir ]; then
	if ! $($utils hasFunction $function_name $script_dir/general.sh); then
			echo 'No docker-compose.yml found!'
			exit 1
	fi
else
	cd $workdir
fi

# Parse .env
if [ -f '.env' ]; then
	$($utils parseEnv .env)
else
	echo 'No .env file!'
fi

# Parse args
source $script_dir/arguments.sh

export CURRENT_ID=$(id -u);
export CURRENT_GID=$(id -g);
export CURRENT_ENV=$env

if [ -f '_docker/d.sh' ]; then
	source _docker/d.sh
fi


# Load functions
source $script_dir/general.sh
source $script_dir/compose.sh
