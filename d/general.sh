#!/bin/bash
function help() { # Show this help
		echo '# ARGS'
		arg_help
		echo

		echo '# GENERAL'
    $utils listFunctions $script_dir/general.sh 1
		# grep "^function" "$script_dir/general.sh" | cut -d ' ' -f2- | sed 's/{ //g'
		echo

		echo '# COMPOSE'
		$utils listFunctions $script_dir/compose.sh 1

		if [[ $workdir && -f $workdir/_docker/d.sh ]]; then
			echo
			echo '# PROJECT'
			$utils listFunctions $workdir/_docker/d.sh 1
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

function pruneimages() {
	[[ $f_arg == '1' ]] && force='-f' || force=''; # Set force or empty
	docker image prune $force
}

# Image
function rebuild() { # Rebuild image $BUILD_IMAGE from _docker (.env)
	pwd
	[ -d _docker ] && path=_docker || path=.
	docker build --rm --build-arg PARENT_IMAGE=$PARENT_IMAGE $path -t $BUILD_IMAGE
}

function runimage() { # Run built image
	docker run -it --rm $BUILD_IMAGE bash -c "${args[*]}"
}

function push() { # Push rebuilt image $BUILD_IMAGE to docker hub
	docker login
	docker push $BUILD_IMAGE
}
