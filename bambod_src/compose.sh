composeCommand() {
	case $env in
		prod)
			echo 'docker-compose -f docker-compose.yml -f docker-compose.prod.yml';
		;;
		staging)
			echo 'docker-compose -f docker-compose.yml -f docker-compose.staging.yml';
		;;
		idle)
			echo 'docker-compose -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.idle.yml';
		;;
		dev)
			if [ -f docker-compose.dev.yml ]; then
				echo 'docker-compose -f docker-compose.yml -f docker-compose.dev.yml';
			else
				echo 'docker-compose'
			fi
		;;
	esac
}

# Functions not listed in help as not prefixed by function
hasContainers() {
	[ $(docker container ls -a -f "name=${APP_NAME}_$1" | wc -l) -gt 1 ]
}

isRunning() {
	[ $(docker container ls -f "name=${APP_NAME}_$env" | wc -l) -gt 1 ]
}

# Image
function rebuild() { # Rebuild image $BUILD_IMAGE from _docker (.env)
	docker build --build-arg PARENT_IMAGE=$PARENT_IMAGE _docker -t $BUILD_IMAGE
}

function push() { # Push rebuilt image $BUILD_IMAGE to docker hub
	docker login
	docker push $BUILD_IMAGE
}

function pull() { # $arg1 = env
	$(composeCommand) pull
}

# Containers
function start() { # Start compose containers, -r = restart
	if [[ $r_arg -eq "1" ]]; then
		stop;
	fi
	$(composeCommand) up -d
}

function stop() { # Stop container
	if isRunning; then
		echo "Stopping ${APP_NAME}_$env containers";
		docker stop $(docker container ls -af "name=${APP_NAME}_${env}*" --format {{.ID}});
	fi
}

function logs() { # Get container log, $arg1 = lines
	[[ -z ${args[0]} ]] && lines='120' || lines=${args[0]};
	echo $lines
	[[ $f_arg -eq "0" ]] && follow='' || follow='-f';
	if hasContainers $env; then
		docker logs $follow $(docker container ls -af "name=${APP_NAME}_${env}_${service}" --format {{.ID}}) --tail	$lines;
	else
		echo "${APP_NAME}_${env}_${service} no container"
	fi
}

function clearlogs() { # Clear logs of container
	if hasContainers; then
		sudo truncate -s 0 $(docker inspect --format='{{.LogPath}}' ${APP_NAME}_${env}_${service})
	else
		echo "${APP_NAME}_${env}_${service} no container"
	fi
}

function bash() { # Enter container with bash
	if isRunning; then
		docker exec -it "${APP_NAME}_${env}_${service}" /bin/bash
	else
		echo "Not running"
	fi
}

function rootbash() { # Enter container as root with bash
	if isRunning; then
		docker exec --user 0 -it "${APP_NAME}_${env}_${service}" /bin/bash
	else
		echo "Not running"
	fi
}

function run() { # Run inside running container
	if isRunning; then
		docker exec -it "${APP_NAME}_${env}_${service}" bash -c "${args[*]}"
	else
		echo 'Not running'
	fi
}

function runsingle() { # Run in parallell container, $arg1 = command
	cmd=$(composeCommand)
	$cmd run --no-deps --rm ${service} bash -c "${args[*]}"
}

# Remote
function mountremote() { # Mount remote to _remote
	if [ -d _remote ]; then
		sshfs ${SRV_USER}@${SRV_DOMAIN}:${SRV_REPO_PATH} _remote
	else
		echo 'No _remote'
	fi
}

function umountremote() { # Unmount _remote
	# fusermount -u _remote
	sudo umount -l _remote
}

function updateremotecli() { # Update remote script
	ssh -t ${SRV_USER}@${SRV_DOMAIN} "\
	cd bambocli && git pull"
}
