# Source main script file
_current_script_dependencies=()

[[ -f "$script_dir/_${script_name}.sh" ]] && source "$script_dir/_${script_name}.sh"
# Add any script extensions if upfind __orb_extensions
_orb_extensions=$(upfind _orb_extensions)
if [[ -n $_orb_extensions && -f $_orb_extensions/${script_name}.sh ]]; then
 	_current_script_extension="$(realpath --relative-to "$script_dir" "$_orb_extensions/${script_name}.sh")"
	_current_script_dependencies+=( $_current_script_extension )
fi

for _file in ${_current_script_dependencies[@]}; do
	source "$script_dir/${_file}"
done
