_orb_history_suffix() {
  local history_index=$1
  [[ -n "$history_index" ]] && echo "_history_$history_index"
}
