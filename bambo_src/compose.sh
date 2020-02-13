hasContainers() {
	[ $(docker container ls -a -f "name=${APP_NAME}_${env}" | wc -l) -gt 1 ]
}
isRunning() {
	[ $(docker container ls -f "name=${APP_NAME}_${env}${s}" | wc -l) -gt 1 ]
}

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

# Containers
function start() { # Start compose containers, -r = restart
	if [[ $r_arg == "1" ]]; then
		stop;
	fi

	if [[ $set_service == '1' ]]; then
		$(composeCommand) up -d --no-deps $service
	else
		$(composeCommand) up -d
	fi
}

function stop() { # Stop container
	if [[ $set_service == '1' ]]; then
		$(composeCommand) stop $service
	else
		$(composeCommand) stop
	fi
}

function pull() { # $arg1 = env
	$(composeCommand) pull
}

function logs() { # Get container log, $arg1 = lines
	[[ -z ${args[0]} ]] && lines='120' || lines=${args[0]};
	[[ $f_arg -eq "0" ]] && follow='' || follow='-f';
	$(composeCommand) logs $follow $service
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

function runremote() {
	ssh -t ${SRV_USER}@${SRV_DOMAIN} "\
	PATH=$PATH:~/bambocli && \
	cd ${SRV_REPO_PATH}/${APP_NAME}-${args[0]} && "${args[@]:1}""
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
