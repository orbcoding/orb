#!/bin/bash
script_files+=(
	docker.sh
	compose.sh
)

# Move to closest docker-compose
compose_file=$(orb utils upfind docker-compose.yml)

if [[ -n  "$compose_file" ]]; then
	cd "${compose_file/%\/*}"

	# Parse .env
	if [ -f '.env' ]; then
		$(orb utils parseenv .env)
	else
		echo 'No .env file!'
	fi

# compose functions require docker-compose.yml
elif orb utils has_public_function $function_name "$script_dir/compose.sh"; then
	orb error "requires docker-compose.yml!"
	exit 1
fi

