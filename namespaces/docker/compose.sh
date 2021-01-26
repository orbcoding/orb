# Containers
# start
declare -A start_args=(
	['1']='env; DEFAULT: $DEFAULT_ENV|dev; IN: prod|staging|dev'
	['-s arg']='start single service'
	['-i']='start idle'
	['-r']='stop first'
); function start() { # Start containers
	# declare
	${_args[-r]} && orb stop "$1" $(orb utils passflags "-s arg")

	local cmd=(
		$(orb composecmd "$1" `orb utils passflags '-s arg'`)
		up -d
		$([[ -n ${_args[-s arg]} ]] && echo " --no-deps ${_args[-s arg]}")
	)

	eval $(orb currentenv $1)
	"${cmd[@]}"
}

# stop
declare -A stop_args=(
	['1']='env; DEFAULT: $DEFAULT_ENV|dev; IN: prod|staging|dev'
	['-s arg']='stop single service'
); function stop() { # Stop containers
	$(orb composecmd "$1") stop ${_args[-s arg]}
}

# logs
declare -A logs_args=(
	['1']='env; DEFAULT: $DEFAULT_ENV|dev; IN: prod|staging|dev'
	['-s arg']='service; DEFAULT: web'
	['-f']='follow; DEFAULT: true;'
	['-l arg']="lines; DEFAULT: 300"
); function logs() { # Get container log
	$(orb composecmd "$1") logs $(orb utils passflags "-f") --tail "${_args[-l arg]}" ${_args[-s arg]}
}

# clearlogs
declare -A clearlogs_args=(
	['1']='env; DEFAULT: $DEFAULT_ENV|dev; IN: prod|staging|dev'
	['-s arg']='service; DEFAULT: web'
); function clearlogs() { # Clear container logs
	sudo truncate -s 0 $(docker inspect --format='{{.LogPath}}' $(orb serviceid $1 `orb utils passflags "-s arg"`))
}

# rm
declare -A rm_args=(
	['1']='env; DEFAULT: $DEFAULT_ENV|dev; IN: prod|staging|dev'
	['-s arg']='rm single service'
); function rm() { # Rm containers
	$(orb composecmd "$1") rm --force ${_args[-s arg]}
}

# pull
declare -A pull_args=(
	['1']='env; DEFAULT: $DEFAULT_ENV|dev; IN: prod|staging|dev'
); function pull() { # Pull compose project images
	$(orb composecmd "$1") pull
}


# serviceid
declare -A serviceid_args=(
	['1']='env; DEFAULT: $DEFAULT_ENV|dev; IN: prod|staging|dev'
	['-s arg']='service; REQUIRED'
); serviceid() {
	$(orb composecmd "$1") ps -q "${_args[-s arg]}"
}


# bash
declare -A bash_args=(
	['1']='env; DEFAULT: $DEFAULT_ENV|dev; IN: prod|staging|dev'
	['-s arg']='service; DEFAULT: $DEFAULT_SERVICE; REQUIRED'
	['-r']='root'
	['-d']='detached, using run'
	['*']='cmd; OPTIONAL'
); function bash() { # Enter container with bash or exec/run cmd
	cmd=( $(orb composecmd $1) )

	# detached
	if ${_args[-d]}; then
		eval $(orb currentenv $1)
		cmd+=( run --no-deps --rm )
	else
		cmd+=( exec )
	fi
	# root
	${_args[-r]} && cmd+=( --user 0 )
	# service
	cmd+=( ${_args['-s arg']} )
	# bash
	bash_cmd=`${_args['*']} && echo -c \"${_args_wildcard[*]}\"`
	cmd+=( /bin/sh -c "[[ ! -f /bin/bash ]] && alias bash=/bin/sh; bash $bash_cmd")
	# exec
	"${cmd[@]}"
}

# ssh
declare -A ssh_args=(
	['1']='IN: prod|staging|nginx|adminer; OPTIONAL'
	['-t']='ssh tty; DEFAULT: true'
	['*']='cmd; OPTIONAL'
); function ssh() { # Run command on remote
	cmd=( PATH=\$PATH:~/orb-cli\; cd ${SRV_REPO_PATH}/${_args[1]} '&&' )

	${_args['*']} && cmd+=( ${_args_wildcard[*]} ) || cmd+=( /bin/bash )

	/bin/ssh $(orb utils passflags -t) "${SRV_USER}@${SRV_DOMAIN}" "${cmd[@]}"
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

function umountremote() { # Umount _remote
	umount -l _remote
}

function updateremotecli() { # Update remote orb-cli
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
); function composecmd() { # Init composecmd with correct compose files
	if [[ ! -f "docker-compose.$1.yml" ]]; then
		cmd=( docker-compose ) # start without envs
	else
		cmd=( docker-compose -f docker-compose.yml -f docker-compose.$1.yml )

		if [[ "${_args[-i]}" == true ]]; then # idle
			[[ -f "docker-compose.idle.yml" ]] && \
			cmd+=( -f docker-compose.idle.yml ) || \
			(echo 'no docker-compose.idle.yml' && exit 1)
		fi
	fi

	echo "${cmd[@]}"
}

# currentenv
declare -A currentenv_args=(
	['1']='env; DEFAULT: $DEFAULT_ENV|dev; IN: prod|staging|dev'
); function currentenv() { # eval $(orb currentenv $env) to export current vars
	cat << EOF
export CURRENT_ENV=$1
export CURRENT_ID=$(id -u)
export CURRENT_GID=$(id -g)
EOF
}

