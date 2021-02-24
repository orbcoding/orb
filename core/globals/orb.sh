local _direct_call=false
local _core_files_only=false
local _global_help_requested=false

declare -A _orb_options=(
  ['--help']='show help'
  ['-d']='direct function call / dont parse/validate arguments declaration'
)

if [[ "$1" == 'core' ]]; then
  _core_files_only=true
fi

# Parse orb flags
if _is_flag "$1"; then
  if [[ "$1" == '--help' ]]; then
    _global_help_requested=true
  else
    local _flags=($(echo "${1:1}" | grep -o .))

    local _flag; for _flag in ${_flags[@]}; do
      case $_flag in
        d)
          _direct_call=true
          ;;
        *)
          local _msg="invalid option\n\nAvailable options:\n\n"
          local _opts=""
          local _opt; for _opt in "${!_orb_options[@]}"; do
            _opts+="  $_opt; ${_orb_options[$_opt]}\n"
          done
          _msg+=$(echo -e "$_opts" | column -tes ';')
          _raise_error "$_msg"
          ;;
      esac
    done
  fi

  shift
fi
