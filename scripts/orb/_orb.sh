# Move to closest docker-compose
compose_file=$(_upfind docker-compose.yml)

if [[ -n  "$compose_file" ]]; then
	cd "${compose_file/%\/*}"

	# Parse .env
	if [ -f '.env' ]; then
		$(_parseenv .env)
	else
		echo 'No .env file!'
	fi

# compose functions require docker-compose.yml
elif _has_public_function "$function_name" "$script_dir/compose.sh"; then
	orb -dc utils raise_error "requires docker-compose.yml!"
fi

