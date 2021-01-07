script_files=()

# Source main script file
[[ -f "$script_dir/_${script_name}.sh" ]] && source "$script_dir/_${script_name}.sh"
# Add any script extensions if upfind _orb_extensions
orb_extensions=$(upfind _orb_extensions)
if [[ -n $orb_extensions && -f $orb_extensions/${script_name}.sh ]]; then
	script_files+=( $(realpath --relative-to "$script_dir" "$orb_extensions/${script_name}.sh") )
fi

for file in ${script_files[@]}; do
	source "$script_dir/$file"
done
