_orb_arguments=(
  --help  'show help'
  -d      'direct function call'
  -r      'restore function declarations after call'
)
# declare -A _orb_arguments=(
#   ['--help']='show help'
#   ['-d']='direct function call, dont parse argument declaration'
#   ['-r']='restore function declarations after call'
# )

# Parse orb flags
if orb_is_any_flag "$1"; then
  if orb_is_flag "$1"; then
    local _orb_flags=($(echo "${1:1}" | grep -o .))

    local _orb_flag; for _orb_flag in ${_orb_flags[@]}; do
      case $_orb_flag in
        d)
          _orb_setting_direct_call=true
          ;;
        r)
          _orb_setting_reload_functions=true
          ;;
        e)
          _orb_extensions+=("$2")
          shift
          ;;
        *)
          local _orb_invalid_flag="-$_flag"
          break
          ;;
      esac
    done

  elif orb_is_verbose_flag "$1"; then
    if [[ "$1" == '--help' ]]; then
      _orb_settings['--help']=true
    else
      local _orb_invalid_flag="$1"
    fi
  fi

  if [[ -n $_orb_invalid_flag ]]; then
    local _orb_opts=""
    local _orb_opt; for _orb_opt in "${_orb_arguments[@]}"; do
      if orb_is_any_flag $_orb_opt; then
        _orb_opts+="  $_orb_opt; " # flag key
      else
        _orb_opts+="${_orb_opt}\n" # flag value
      fi
    done

    local _orb_error_msg="invalid option $_orb_invalid_flag\n\nAvailable options:\n\n"
    _orb_error_msg+=$(echo -e "$_orb_opts" | column -tes ';')
    orb_raise_error -d "$(orb_bold)orb$(orb_normal)" "$_orb_error_msg"
  fi

  shift
fi
