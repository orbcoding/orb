# Containers
# start
declare -A start_args=(
	['1']='env; DEFAULT: $DEFAULT_ENV|dev; IN: prod|staging|dev'
	['-s arg']='start single service'
	['-i']='start idle'
	['-r']='stop first'
); function start() { # Start compose containers, $1 = env, -r = restart, -e = spec env if $1 = idle
	set_env $1

	[[ -n ${args[-r]} ]] && orb stop $1 `orb utils passflags "-s arg"`

	cmd="$(orb composecmd "$1" `orb utils passflags -i`) up -d "
	[[ -n ${args[-s arg]} ]] && cmd+=" --no-deps ${args[-s arg]}"

	$cmd
}

# stop
declare -A stop_args=(
	['1']='env; DEFAULT: $DEFAULT_ENV|dev; IN: prod|staging|dev'
	['-s arg']='stop single service'
); function stop() { # Stop containers
	$(orb composecmd $1) stop ${args[-s arg]}
}

# logs
declare -A logs_args=(
	['1']='env; DEFAULT: $DEFAULT_ENV|dev; IN: prod|staging|dev'
	['-s arg']='service; DEFAULT: web'
	['-f']='follow; DEFAULT: true;'
	['-l arg']="lines; DEFAULT: 300"
); function logs() { # Get container log
	# orb print_args
$(orb composecmd $(orb utils echoerr -e hej))
	# $(orb composecmd "$1") logs $(orb utils passflags "-f") --tail "${args[-l arg]}" ${args[-s arg]}
}

# clearlogs
declare -A clearlogs_args=(
	['1']='env; DEFAULT: $DEFAULT_ENV|dev; IN: prod|staging|dev'
	['-s arg']='service; DEFAULT: web'
); function clearlogs() { # Clear container logs
	sudo truncate -s 0 $(docker inspect --format='{{.LogPath}}' $(serviceid $1 `orb utils passflags "-s arg"`))
}

# rm
declare -A rm_args=(
	['1']='env; DEFAULT: $DEFAULT_ENV|dev; IN: prod|staging|dev'
	['-s arg']='rm single service'
); function rm() { # Rm containers
	$(orb composecmd $1) rm --force ${args[-s arg]}
}

# pull
declare -A pull_args=(
	['1']='env; DEFAULT: $DEFAULT_ENV|dev; IN: prod|staging|dev'
); function pull() { # Pull compose images
	$(composecmd $1) pull
}


# serviceid
declare -A serviceid_args=(
	['1']='env; DEFAULT: $DEFAULT_ENV|dev; IN: prod|staging|dev'
	['-s arg']='service; REQUIRED'
); serviceid() {
	$(orb composecmd $1) ps -q "${args[-s arg]}"
}


# bash
declare -A bash_args=(
	['-e arg']='env; DEFAULT: $DEFAULT_ENV|dev'
	['-s arg']='service; DEFAULT: $DEFAULT_SERVICE; REQUIRED'
	['-r']='root'
	['-d']='detached, using run'
	['*']='cmd; OPTIONAL'
); function bash() { # Enter container with bash or exec/run cmd
	cmd=( $(composecmd $(orb utils passflags "-e arg")))

	# detached
	if ${args[-d]}; then
		set_env ${args[-e arg]}
		cmd+=( run --no-deps --rm )
	else
		cmd+=( exec )
	fi
	# root
	${args[-r]} && cmd+=( --user 0 )
	# service
	cmd+=( ${args['-s arg']} )
	# bash
	bash_cmd=`${args['*']} && echo -c \"${args_wildcard[*]}\"`
	cmd+=( /bin/sh -c "[[ ! -f /bin/bash ]] && alias bash=/bin/sh; bash $bash_cmd")
	# exec
	echo "${cmd[@]}"
	"${cmd[@]}"
}

# ssh
declare -A ssh_args=(
	['1']='IN: prod|staging|nginx|adminer; OPTIONAL'
	['-t']='ssh tty; DEFAULT: true'
	['*']='cmd; OPTIONAL'
); function ssh() { # Run command on remote, $1 = prod/staging/nginx, $2 = command
	cmd=( PATH=\$PATH:~/orb-cli\; cd ${SRV_REPO_PATH}/${args[1]} '&&' )

	${args['*']} && cmd+=( ${args_wildcard[*]} ) || cmd+=( /bin/bash )

	/bin/bash -c "echo hej"

	# /bin/ssh $(orb utils passflags -t) "${SRV_USER}@${SRV_DOMAIN}" "${cmd[@]}"
}

###########
# Remote
###########
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
	cd orbcli && git pull"
}

##########
# HELPERS
##########
# composecmd
declare -A composecmd_args=(
	['1']='env; IN: prod|staging|dev'
	['-i']='start idle'
); function composecmd() { # Init composecmd with correct env files
	if [[ ! -f "docker-compose.$1.yml" ]]; then
		cmd=( docker-compose ) # start without envs
	else
		cmd=( docker-compose -f docker-compose.yml -f docker-compose.$1.yml )

		if [[ "${args[-i]}" == true ]]; then # idle
			[[ -f "docker-compose.idle.yml" ]] && \
			cmd+=( -f docker-compose.idle.yml ) || \
			(echo 'no docker-compose.idle.yml' && exit 1)
		fi
	fi

	echo "${cmd[@]}"
}

declare -A set_env_args=(
	['1']='env; DEFAULT: $DEFAULT_ENV|dev; IN: prod|staging|dev'
); set_env() {
	export CURRENT_ENV="$1"
	export CURRENT_ID="$(id -u)";
	export CURRENT_GID="$(id -g)";
}

