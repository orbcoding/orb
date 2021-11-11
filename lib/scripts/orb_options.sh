declare -A _orb_options=(
  ['--help']='false'
  ['-d']='false'
)

declare -A _orb_options_declaration=(
  ['--help']='show help'
  ['-d']='direct function call, dont parse argument declaration'
)

$_orb_sourced && return

# Parse orb flags
if _is_flag "$1"; then
  if [[ "$1" == '--help' ]]; then
    _orb_options['--help']=true
  else
    local _flags=($(echo "${1:1}" | grep -o .))

    local _flag; for _flag in ${_flags[@]}; do
      case $_flag in
        d)
          _orb_options['-d']=true
          ;;
        *)
          local _msg="invalid option -$_flag\n\nAvailable options:\n\n"
          local _opts=""
          local _opt; for _opt in "${!_orb_options_declaration[@]}"; do
            _opts+="  $_opt; ${_orb_options_declaration[$_opt]}\n"
          done
          _msg+=$(echo -e "$_opts" | column -tes ';')
          _raise_error -d "$(_bold)orb$(_normal)" "$_msg"
          ;;
      esac
    done
  fi

  shift
fi
