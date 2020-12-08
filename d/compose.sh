composecommand() {
	case ${args[-e arg]} in
		prod)
			echo 'docker-compose -f docker-compose.yml -f docker-compose.prod.yml';
		;;
		staging)
			echo 'docker-compose -f docker-compose.yml -f docker-compose.staging.yml';
		;;
		idle)
			echo "docker-compose -f docker-compose.yml -f docker-compose.${args[-e argZ]}.yml -f docker-compose.idle.yml";
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

serviceid() {
	echo $($(composecommand) ps -q $service)
}

# Containers
declare -A start_args=(
	['1']='env; DEFAULT: $DEFAULT_ENV|dev; IN: prod|staging|idle|dev'
	["-e arg"]='env if $1 = idle; DEFAULT: $DEFAULT_ENV|dev; IN: prod|staging|idle|dev'
	['-r']='restart if already started'
	['-s arg']='start single service'
)
function start() { # Start compose containers, $1 = env, -r = restart, -e = spec env if $1 = idle
	export CURRENT_ENV=$1
	export CURRENT_ID=$(id -u);
	export CURRENT_GID=$(id -g);

	[[ ${args[-r]} == true ]] && stop

	if [[ -n ${args[-s]} ]]; then
		$(composecommand) up -d --no-deps $service
	else
		$(composecommand) up -d
	fi
}

function stop() { # Stop containers
	[[ ! -z ${args[0]} ]] && env=${args[0]}
	if [[ $set_service == '1' ]]; then
		$(composecommand) stop $service
	else
		$(composecommand) stop
	fi
}

function rm() { # Rm containers
	[[ -n ${args[0]} ]] && env=${args[0]}
	if [[ $set_service == '1' ]]; then
		$(composecommand) rm $service --force
	else
		$(composecommand) rm --force
	fi
}

function pull() { # Pull compose images
	$(composecommand) pull
}

function logs() { # Get container log, $1 = lines, -f = follow
	lines=${args[0]-300} # 300 default
	# [[ -z ${args[0]} ]] && lines='300' || lines=${args[0]};
	[[ $f_arg -eq "0" ]] && follow='' || follow='-f';
	$(composecommand) logs  --tail $lines $follow $service
}

function clearlogs() { # Clear container logs
	sudo truncate -s 0 $(docker inspect --format='{{.LogPath}}' $(serviceid))
}

function bash() { # Enter container with bash
	docker exec -it "$(serviceid)" /bin/bash
}

function rootbash() { # Enter container as root with bash
	docker exec --user 0 -it "$(serviceid)" /bin/bash
}

function run() { # Run inside running container, $1 = command
	docker exec -it "$(serviceid)" bash -ci "${args[*]}"
}

function runsingle() { # Run in parallell container, $1 = command
	$(composecommand) run --no-deps --rm ${service} bash -ci "${args[*]}"
}

function runremote() { # Run command on remote, $1 = prod/staging/nginx, $2 = command
	ssh -t ${SRV_USER}@${SRV_DOMAIN} "\
	PATH=$PATH:~/bambocli && \
	cd ${SRV_REPO_PATH}/${args[0]} && "${args[@]:1}""
}

# Remote
function mountremote() { # Mount remote to _remote
	if [ -d _remote ]; then
		sshfs -o follow_symlinks ${SRV_USER}@${SRV_DOMAIN}:${SRV_REPO_PATH} _remote
	else
		echo 'No _remote'
	fi
}

function umountremote() { # Unmount _remote
	sudo umount -l _remote
}

function updateremotecli() { # Update remote script
	ssh -t ${SRV_USER}@${SRV_DOMAIN} "\
	cd bambocli && git pull"
}
