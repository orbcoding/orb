_direct_call=false
_core_files_only=false

# Parse orb flags
if [[ ${1:0:1} == '-' ]]; then
  _flags=($(echo "${1:1}" | grep -o .))

  for _flag in ${_flags[@]}; do
    case $_flag in
      d)
        _direct_call=true
        ;;
      c)
        _core_files_only=true
        ;;
    esac
  done

  shift
fi
