# Move to closest docker-compose
compose_file=$(_find_closest docker-compose.yml)

if [[ -n  "$compose_file" ]]; then
	cd "${compose_file/%\/*}"

	# Parse .env
	if [ -f '.env' ]; then
		_parse_env .env
	else
		echo 'No .env file!'
	fi

# compose functions require docker-compose.yml
elif _has_public_function "$function_name" "$namespace_dir/compose.sh"; then
	orb -c utils raise_error "requires docker-compose.yml!"
fi

