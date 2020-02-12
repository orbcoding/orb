#!/bin/bash
function help() { # Show this help
		echo '# ARGS'
		arg_help
		echo

		echo '# GENERAL'
    grep "^function" "$script_dir/bambo_src/general.sh" | cut -d ' ' -f2- | sed 's/{ //g'
		echo

		echo '# COMPOSE'
    grep "^function" "$script_dir/bambo_src/compose.sh" | cut -d ' ' -f2- | sed 's/{ //g'

		if [[ $workdir && -f $workdir/_docker/scripts.sh ]]; then
			echo
			echo '# PROJECT'
			grep "^function" "$workdir/_docker/scripts.sh" | cut -d ' ' -f2- | sed 's/{ //g'
		fi
}


function list() { # List containers and images
	docker ps -a
	echo
	docker images
}

function df() { # Get docker disk usage
	docker system df
}

function pruneall() { # Prune all stopped and unused including volumes, -f = force
	[[ $f_arg == '1' ]] && force='-f' || force=''; # Set force or empty
	docker system prune --all --volumes $force;
}



