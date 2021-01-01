#!/bin/bash
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

function prunecontainers() { # Prune all stopped containers, -f = force
	[[ $f_arg == '1' ]] && force='-f' || force=''; # Set force or empty
	docker container prune $force;
}

function pruneimages() { # remove all images, -f = force
	[[ $f_arg == '1' ]] && force='-f' || force=''; # Set force or empty
	docker image prune $force
}

function stopall() { # stop all containers
	docker stop $(docker ps -a -q)
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
