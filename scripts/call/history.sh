[[ -z $_orb_function_name ]] && return

if (( $_orb_history_index < $_orb_history_max_length - 1 )); then
  _orb_last_move_i=$_orb_history_index
else
  _orb_last_move_i=$(( $_orb_history_max_length - 2 ))
fi

# Move variables up one index
# Loop through history in reverse
# skipping last entry if reached max history length
local _orb_i; for _orb_i in $(seq $_orb_last_move_i -1 0); do
  local _orb_history_var; for _orb_history_var in "${_orb_history_variables[@]}"; do
    local _orb_old_name="${_orb_history_var}_history_${_orb_i}"
    local _orb_new_name="${_orb_history_var}_history_$(( $_orb_i + 1 ))"

    eval $(_orb_rename_variable $_orb_old_name $_orb_new_name)
  done
done; 

# Set the new 0 index
local _orb_history_var; for _orb_history_var in "${_orb_history_variables[@]}"; do
    local _orb_new_name="${_orb_history_var}_history_0"
    
    eval $(_orb_rename_variable $_orb_history_var $_orb_new_name)
done

(( _orb_history_index++ ))

unset _orb_i _orb_last_move_i _orb_history_var _orb_old_name _orb_new_name
