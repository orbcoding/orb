Include lib/arguments/collection.sh
Include lib/arguments/assignment.sh
Include lib/arguments/validation.sh
Include lib/utils/argument.sh
Include lib/scripts/call/variables.sh
Include lib/declaration/checkers.sh

# _orb_parse_function_args
Describe '_orb_parse_function_args'
  _orb_print_function_help() { echo_fn; }
  _orb_parse_args() { echo_fn "$@"; }

	It 'prints function help if 1 == --help'
    When run _orb_parse_function_args --help
    The output should equal _orb_print_function_help
  End

	It 'sets directly to positional args if _orb_settings_direct_call'
    _orb_setting_direct_call=true
    When call _orb_parse_function_args 1 2 3
    The variable "_orb_args_positional[@]" should equal "1 2 3"
  End

	It 'parses args by default'
    When call _orb_parse_function_args 1 2 3
    The output should equal "_orb_parse_args 1 2 3"
  End
End

# _orb_parse_args
Describe '_orb_parse_args'
  orb_raise_error() { echo "$@"; exit 1; }
  _orb_collect_args() { spec_fns+=($(echo_fn)); }
  _orb_set_arg_defaults() { spec_fns+=($(echo_fn)); }  
  _orb_args_post_validation() { spec_fns+=($(echo_fn)); }
  _orb_set_args_positional() { spec_fns+=($(echo_fn)); }
  
  Context 'no args declared'
    It 'raises error if receive input args'
      When run _orb_parse_args 1 2 3
      The status should be failure 
      The output should equal "does not accept arguments" 
    End

    It 'returns without parsing if no args received'
      When call _orb_parse_args
      The status should be success
      The variable "spec_fns[@]" should be blank 
    End
  End

  Context 'args declared'
    _orb_declared_args=(
      var = 1 
    )

    It 'parses args'
      When call _orb_parse_args 1 2 3
      The status should be success
      The variable "spec_fns[@]" should equal "_orb_collect_args _orb_set_arg_defaults _orb_args_post_validation _orb_set_args_positional"
    End

    It 'continues even if no args received'
      When call _orb_parse_args
      The status should be success
      The variable "spec_fns[@]" should equal "_orb_collect_args _orb_set_arg_defaults _orb_args_post_validation _orb_set_args_positional"
    End
  End
End

# _orb_collect_args
Describe '_orb_collect_args'
  args_remaining=(-f hello -b-)
  _orb_collect_flag_arg() { spec_fns+=($(echo_fn)); _orb_shift_args; }
  _orb_collect_block_arg() { spec_fns+=($(echo_fn)); _orb_shift_args; }
  _orb_collect_inline_arg() { spec_fns+=($(echo_fn)); _orb_shift_args; }

  It 'collects args'
    When call _orb_collect_args
    The status should be success
    The variable "spec_fns[@]" should equal "_orb_collect_flag_arg _orb_collect_inline_arg _orb_collect_block_arg"
  End
End

# _orb_collect_flag_arg
Describe '_orb_collect_flag_arg'
  _orb_assign_boolean_flag() { echo_fn $@; }
  _orb_assign_flagged_arg() { echo_fn $@; }
  # _orb_try_parse_multiple_flags() { echo_fn $@; }
  _orb_try_inline_arg_fallback() { echo_fn $@; }

  It 'collects declared boolean flag'
    _orb_declared_args=(-f)
    When call _orb_collect_flag_arg -f
    The status should be success
    The output should equal "_orb_assign_boolean_flag -f"
  End

  It 'collects declared flagged args'
    _orb_declared_args=(-f)
    declare -A _orb_declared_arg_suffixes=([-f]=1)
    When call _orb_collect_flag_arg -f
    The status should be success
    The output should equal "_orb_assign_flagged_arg -f"
  End
  
  It 'tries to parse multiple flags and inline args if no flags declared'
    _orb_declared_args=(-f)
    When call _orb_collect_flag_arg -a
    The status should be success
    The output should equal "_orb_try_inline_arg_fallback -a -a"
  End
End


# _orb_collect_block_arg
Describe '_orb_collect_block_arg'
  _orb_assign_block() { echo_fn $@; }
  _orb_try_inline_arg_fallback() { echo_fn $@; }
  _orb_declared_args=(-b-)

  It 'collects blocks'
    When call _orb_collect_block_arg -b-
    The status should be success
    The output should equal "_orb_assign_block -b-"
  End

  It 'tries inline arg fallback if no block declared'
    When call _orb_collect_block_arg -f-
    The status should be success
    The output should equal "_orb_try_inline_arg_fallback -f- -f-"
  End
End


# _orb_collect_inline_arg
Describe '_orb_collect_inline_arg'
  args_count=1
  _orb_assign_dash_wildcard() { echo_fn $@; }
  _orb_assign_inline_arg() { echo_fn $@; }
  _orb_assign_rest() { echo_fn $@; }
  _orb_raise_invalid_arg() { echo_fn $@ && return 1; }

  It 'collects dash wildcard first'
    _orb_declared_args=(--)
    When call _orb_collect_inline_arg --
    The status should be success
    The output should equal "_orb_assign_dash_wildcard"
  End

  It 'collects numbered args'
    _orb_declared_args=(1)
    When call _orb_collect_inline_arg 1
    The status should be success
    The output should equal "_orb_assign_inline_arg 1"
  End

  It 'falls back to wildcard if declared'
    _orb_declared_args=(...)
    When call _orb_collect_inline_arg 1
    The status should be success
    The output should equal "_orb_assign_rest"
  End

  It 'fails if no wildcard fallback declared'
    _orb_declared_args=(-f)
    When call _orb_collect_inline_arg 1
    The status should be failure
    The output should equal "_orb_raise_invalid_arg 1 with value 1"
  End
End


# _orb_try_inline_arg_fallback
Describe '_orb_try_inline_arg_fallback'
  args_count=1
  _orb_assign_inline_arg() { echo_fn $@; }
  _orb_assign_rest() { echo_fn $@; }
  _orb_raise_invalid_arg() { echo_fn "$@"; exit 1; }
  args_count=1
  _orb_declared_args=(1 ...)
  declare -a _orb_declared_catchs=(flag block dash)

  It 'assigns flag to nr arg if catch declared'
    declare -A _orb_declared_catchs_start_indexes=([1]=0)
    declare -A _orb_declared_catchs_lengths=([1]=1)
    When call _orb_try_inline_arg_fallback -f -f
    The status should be success
    The output should equal "_orb_assign_inline_arg -f"
  End
  
  It 'assigns flag to rest if catch properly declared'
    declare -A _orb_declared_catchs_start_indexes=([...]=0)
    declare -A _orb_declared_catchs_lengths=([...]=1)
    When call _orb_try_inline_arg_fallback -f -f
    The status should be success
    The output should equal "_orb_assign_rest"
  End
  
  It 'works for blocks'
    declare -A _orb_declared_catchs_start_indexes=([...]=1)
    declare -A _orb_declared_catchs_lengths=([...]=1)
    When call _orb_try_inline_arg_fallback -f- -f-
    The status should be success
    The output should equal "_orb_assign_rest"
  End
  
  It 'fails unless catch specified'
    declare -A _orb_declared_catchs_start_indexes
    declare -A _orb_declared_catchs_lengths
    When run _orb_try_inline_arg_fallback -f- -f-
    The status should be failure
    The output should equal "_orb_raise_invalid_arg -f-"
  End
End

# _orb_try_parse_multiple_flags
Describe '_orb_try_parse_multiple_flags'
  _orb_assign_boolean_flag() { spec_fns+=($(echo_fn $@)); }
  _orb_assign_flagged_arg() { spec_fns+=($(echo_fn $@)); }
  _orb_shift_args() { spec_fns+=($(echo_fn $@)); }

  It 'fails on verbose flags'
    When call _orb_try_parse_multiple_flags --verbose-flag
    The status should be failure
  End

  It 'succeeds on defined flags'
    _orb_declared_args=(-f -a)
    When call _orb_try_parse_multiple_flags -fa
    The status should be success
    The variable "spec_fns[@]" should equal "_orb_assign_boolean_flag -f 0 _orb_assign_boolean_flag -a 0 _orb_shift_args 1"
  End

  It 'shifts args according to highest suffix'
    _orb_declared_args=(-f -a)
    declare -A _orb_declared_arg_suffixes=([-f]=3 [-a]=2)
    When call _orb_try_parse_multiple_flags -fa
    The status should be success
    The variable "spec_fns[@]" should equal "_orb_assign_flagged_arg -f 0 _orb_assign_flagged_arg -a 0 _orb_shift_args 3"
  End
End
