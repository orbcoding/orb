Include functions/arguments/collection.sh
Include functions/arguments/assignment.sh
Include functions/arguments/validation.sh
Include functions/utils/argument.sh
Include functions/utils/utils.sh
Include scripts/call/variables.sh
Include functions/declaration/checkers.sh
Include functions/declaration/getters.sh


# _orb_collect_function_args
Describe '_orb_collect_function_args'
  _orb_raise_error() { echo "$@"; exit 1; }
  _orb_collect_args() { spec_fns+=($(echo_fn)); }
  _orb_post_validate_args() { spec_fns+=($(echo_fn)); }
  _orb_set_default_arg_values() { spec_fns+=($(echo_fn)); }
  
  Context 'no args declared'
    It 'raises error if receive input args'
      When run _orb_collect_function_args 1 2 3
      The status should be failure 
      The output should equal "does not accept arguments" 
    End

    It 'returns without parsing if no args received'
      When call _orb_collect_function_args
      The status should be success
      The variable "spec_fns[@]" should be blank 
    End
  End

  Context 'args declared'
    _orb_declared_args=(
      var = 1 
    )

    It 'parses args'
      When call _orb_collect_function_args 1 2 3
      The status should be success
      The variable "spec_fns[@]" should equal "_orb_collect_args _orb_set_default_arg_values _orb_post_validate_args"
    End

    It 'continues even if no args received'
      When call _orb_collect_function_args
      The status should be success
      The variable "spec_fns[@]" should equal "_orb_collect_args _orb_set_default_arg_values _orb_post_validate_args"
    End
  End
End

# _orb_collect_args
Describe '_orb_collect_args'
  _orb_args_remaining=(-f hello -b-)
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
  # _orb_try_collect_multiple_flags() { echo_fn $@; }
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
  _orb_args_count=1
  _orb_assign_dash() { echo_fn $@; }
  _orb_assign_inline_arg() { echo_fn $@; }
  _orb_assign_rest() { echo_fn $@; }
  _orb_raise_invalid_arg() { echo_fn $@ && return 1; }

  It 'collects dash rest first'
    _orb_declared_args=(--)
    When call _orb_collect_inline_arg --
    The status should be success
    The output should equal "_orb_assign_dash"
  End

  It 'collects numbered args'
    _orb_declared_args=(1)
    When call _orb_collect_inline_arg 1
    The status should be success
    The output should equal "_orb_assign_inline_arg 1"
  End

  It 'falls back to rest if declared'
    _orb_declared_args=(...)
    When call _orb_collect_inline_arg 1
    The status should be success
    The output should equal "_orb_assign_rest"
  End

  It 'fails if no rest fallback declared'
    _orb_declared_args=(-f)
    When call _orb_collect_inline_arg 1
    The status should be failure
    The output should equal "_orb_raise_invalid_arg 1 with value 1"
  End
End


# _orb_try_inline_arg_fallback
Describe '_orb_try_inline_arg_fallback'
  _orb_args_count=1
  _orb_assign_inline_arg() { echo_fn $@; }
  _orb_assign_rest() { echo_fn $@; }
  _orb_raise_invalid_arg() { echo_fn "$@"; exit 1; }
  _orb_args_count=1
  _orb_declared_args=(1 ...)
  declare -a _orb_declared_option_values=(flag block dash)

  It 'assigns flag to nr arg if catch declared'
    declare -A _orb_declared_option_start_indexes=([Catch:]="0 -")
    declare -A _orb_declared_option_lengths=([Catch:]="1 -")
    When call _orb_try_inline_arg_fallback -f -f
    The status should be success
    The output should equal "_orb_assign_inline_arg -f"
  End
  
  It 'assigns flag to rest if catch properly declared'
    declare -A _orb_declared_option_start_indexes=([Catch:]="- 0")
    declare -A _orb_declared_option_lengths=([Catch:]="- 1")
    When call _orb_try_inline_arg_fallback -f -f
    The status should be success
    The output should equal "_orb_assign_rest"
  End
  
  It 'works for blocks'
    declare -A _orb_declared_option_start_indexes=([Catch:]="- 1")
    declare -A _orb_declared_option_lengths=([Catch:]="- 1")
    When call _orb_try_inline_arg_fallback -f- -f-
    The status should be success
    The output should equal "_orb_assign_rest"
  End
  
  It 'fails unless catch specified'
    declare -A _orb_declared_option_start_indexes=("- -")
    declare -A _orb_declared_option_lengths=("- -")
    When run _orb_try_inline_arg_fallback -f- -f-
    The status should be failure
    The output should equal "_orb_raise_invalid_arg -f-"
  End
End

# _orb_try_collect_multiple_flags
Describe '_orb_try_collect_multiple_flags'
  _orb_assign_boolean_flag() { spec_fns+=($(echo_fn $@)); }
  _orb_assign_flagged_arg() { spec_fns+=($(echo_fn $@)); }
  _orb_shift_args() { spec_fns+=($(echo_fn $@)); }

  It 'fails on verbose flags'
    When call _orb_try_collect_multiple_flags --verbose-flag
    The status should be failure
  End

  It 'succeeds on defined flags'
    _orb_declared_args=(-f -a)
    When call _orb_try_collect_multiple_flags -fa
    The status should be success
    The variable "spec_fns[@]" should equal "_orb_assign_boolean_flag -f 0 _orb_assign_boolean_flag -a 0 _orb_shift_args 1"
  End

  It 'shifts args according to highest suffix + 1'
    _orb_declared_args=(-f -a)
    declare -A _orb_declared_arg_suffixes=([-f]=3 [-a]=2)
    When call _orb_try_collect_multiple_flags -fa
    The status should be success
    The variable "spec_fns[@]" should equal "_orb_assign_flagged_arg -f 0 _orb_assign_flagged_arg -a 0 _orb_shift_args 4"
  End
End

Describe '_orb_set_default_arg_values'
  _orb_set_default_from_declaration() { spec_args+=("$@"); }
  _orb_declared_args=(1 -f)

  It 'sets from declaration if value not already set'
    _orb_has_arg_value() { return 1; }

    When call _orb_set_default_arg_values
    The variable "spec_args[@]" should eq "1 -f"
  End

  It 'Does not set from declaration if value already set'
    _orb_has_arg_value() { return 0; }

    When call _orb_set_default_arg_values
    The variable "spec_args[@]" should be undefined
  End
End
