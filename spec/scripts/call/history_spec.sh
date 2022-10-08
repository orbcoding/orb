spec_fn_orb=(
  1 = first
)

spec_fn_orb2=(${spec_fn_orb[@]})
spec_fn_orb3=(${spec_fn_orb[@]})
spec_fn_orb4=(${spec_fn_orb[@]})
spec_fn_orb5=(${spec_fn_orb[@]})
spec_fn_orb() { source $_orb_root/bin/orb; spec_fn_orb2;}
spec_fn_orb2() { source $_orb_root/bin/orb; spec_fn_orb3; }
spec_fn_orb3() { source $_orb_root/bin/orb; spec_fn_orb4; }
spec_fn_orb4() { source $_orb_root/bin/orb; spec_fn_orb5; }
spec_fn_orb5() { source $_orb_root/bin/orb; callback; }



Describe 'history.sh'
  It 'should store history variables with index'
    callback() {
      # first history item is last called
      [[ $_orb_function_name == spec_fn_orb5 ]] || return 1
      [[ $_orb_function_name_history_0 == spec_fn_orb4 ]] || return 1

      for var in ${_orb_history_variables[@]}; do
        # defined 
        declare -p "${var}_history_0" >/dev/null || return 1
        declare -p "${var}_history_1" >/dev/null || return 1
        declare -p "${var}_history_2" >/dev/null || return 1
        # undefined because of max history=3
        declare -p "${var}_history_3" 2>/dev/null && return 1
        return 0
      done
    }

    When call spec_fn_orb
    The status should be success
  End

  It 'should only store as many histories as we have'
    spec_fn_orb4() {
      for var in ${_orb_history_variables[@]}; do
        # defined 
        declare -p "${var}_history_0" >/dev/null || return 1
        declare -p "${var}_history_1" >/dev/null || return 1
        declare -p "${var}_history_2" 2>/dev/null && return 1
        return 0
      done
    }

    When call spec_fn_orb
    The status should be success
  End
End
