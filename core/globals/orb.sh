_direct_call=false
_core_files_only=false
_global_help_requested=false

declare -A _orb_options=(
  ['--help']='show help'
  ['-d']='direct function call / dont parse/validate arguments declaration'
  ['-c']='core files only / dont parse extension files'
)

# Parse orb flags
if _is_flag "$1"; then
  if [[ "$1" == '--help' ]]; then
    _global_help_requested=true
  else
    _flags=($(echo "${1:1}" | grep -o .))

    for _flag in ${_flags[@]}; do
      case $_flag in
        d)
          _direct_call=true
          ;;
        c)
          _core_files_only=true
          ;;
        *)
          _msg="invalid option\n\nAvailable options:\n\n"
          _opts=""
          for _opt in "${!_orb_options[@]}"; do
            _opts+="  $_opt; ${_orb_options[$_opt]}\n"
          done
          _msg+=$(echo -e "$_opts" | column -tes ';')
          orb -c utils raise_error "$_msg"
          ;;
      esac
    done; unset _flag _flags
  fi

  shift
fi
