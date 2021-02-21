#!/bin/bash
function list()  { # List containers and images
	docker ps -a
	echo
	docker images
}

function df() { # Get docker disk usage
	docker system df
}

declare -A pruneall_args=(
	['-f']='force'
); function pruneall() { # Prune all stopped and unused including volumes
	docker system prune --all --volumes $(orb core pass_flags -f);
}

declare -A prunecontainers_args=(
	['-f']='force'
); function prunecontainers() { # Prune all stopped containers, -f = force
	docker container prune $(orb core pass_flags -f);
}

declare -A pruneimages_args=(
	['-f']='force'
); function pruneimages() { # remove all images, -f = force
	docker image prune $(orb core pass_flags -f)
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
