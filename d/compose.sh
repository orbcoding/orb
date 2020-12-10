# Containers
declare -A start_args=(
	['1']='env; DEFAULT: $DEFAULT_ENV|dev; IN: prod|staging|dev'
	['-s arg']='start single service'
	['-i']='start idle'
	['-r']='stop first'
); function start() { # Start compose containers, $1 = env, -r = restart, -e = spec env if $1 = idle
	export CURRENT_ENV="$1"
	export CURRENT_ID="$(id -u)";
	export CURRENT_GID="$(id -g)";

	[[ -n ${args[-r]} ]] && bambo stop $1 `passflags "-s arg"`

	cmd="$(bambo composecmd "$1" `passflags -i`) up -d "
	[[ -n ${args[-s arg]} ]] && cmd+=" --no-deps ${args[-s arg]}"

	$cmd
}


declare -A stop_args=(
	['1']='env; DEFAULT: $DEFAULT_ENV|dev; IN: prod|staging|dev'
	['-s arg']='stop single service'
); function stop() { # Stop containers
	$(bambo composecmd $1) stop ${args[-s arg]}
}


declare -A logs_args=(
	['1']='env; DEFAULT: $DEFAULT_ENV|dev; IN: prod|staging|dev'
	['-s arg']='service; DEFAULT: web'
	['-nf']='no follow;'
	['-l arg']="lines; DEFAULT: 300"
); function logs() { # Get container log
	cmd="$(bambo composecmd $1) logs --tail ${args[-l arg]}"
	[[ -z ${args[-nf]} ]] && cmd+=" -f" # follow unless nf
	cmd+=" ${args[-s arg]}"
	$cmd
}


declare -A clearlogs_args=(
	['1']='env; DEFAULT: $DEFAULT_ENV|dev; IN: prod|staging|dev'
	['-s arg']='service; DEFAULT: web'
); function clearlogs() { # Clear container logs
	sudo truncate -s 0 $(docker inspect --format='{{.LogPath}}' $(serviceid $1 `passflags "-s arg"`))
}


declare -A rm_args=(
	['1']='env; DEFAULT: $DEFAULT_ENV|dev; IN: prod|staging|dev'
	['-s arg']='rm single service'
); function rm() { # Rm containers
	$(bambo composecmd $1) rm --force ${args[-s arg]}
}


declare -A pull_args=(
	['1']='env; DEFAULT: $DEFAULT_ENV|dev; IN: prod|staging|dev'
); function pull() { # Pull compose images
	$(composecmd $1) pull
}


# Mostly Internal
declare -A composecmd_args=(
	['1']='env; IN: prod|staging|dev; REQUIRED'
	['-s arg']='service name'
	['-i']='start idle'
); composecmd() { #
	# Select files for cmd
	if [[ ! -f "docker-compose.$1.yml" ]]; then
		cmd='docker-compose' # start without envs
	else
		cmd="docker-compose -f docker-compose.yml -f docker-compose.$1.yml"

		if [[ "${args[-i]}" == true ]]; then # idle
			[[ -f "docker-compose.idle.yml" ]] && \
			cmd+=' -f docker-compose.idle.yml' || \
			(echo 'no docker-compose.idle.yml' && exit 1)
		fi
	fi

	echo "$cmd"
}


declare -A serviceid_args=(
	['1']='env; DEFAULT: $DEFAULT_ENV|dev; IN: prod|staging|dev'
	['-s arg']='service; REQUIRED'
); serviceid() {
	$(bambo composecmd $1) ps -q ${args[-s arg]}
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

declare -A runsingle_args=(
	['-e']='env; DEFAULT: $DEFAULT_ENV|dev; IN: prod|staging|dev'
	['*']='cmd;'
); function runsingle() { # Run in parallell container, $1 = command
	echo "$@"
	# $(bambo composecmd $1) run --no-deps --rm ${service} bash -ci "${args[*]}"
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
