Include functions/arguments/assignment.sh
Include functions/arguments/validation.sh
Include scripts/call/variables.sh
Include functions/declaration/checkers.sh
Include functions/arguments/checkers.sh
Include functions/utils/argument.sh

declare flag
declare dash
declare -A _orb_declared_vars=(
  [1]=one 
  [-f]=flag 
  [--]=dash 
  [-b-]=block 
  [...]=rest
)

# _orb_assign_arg_value
Describe '_orb_assign_arg_value'
  It 'should assign to arg values arrs'
    _orb_assign_arg_value -- some values come before
    When call _orb_assign_arg_value -f "some values after"
    The variable "_orb_args_values[@]" should equal "some values come before some values after"
    The variable "_orb_args_values_start_indexes[--]" should equal 0
    The variable "_orb_args_values_lengths[--]" should equal 4
    The variable "_orb_args_values_start_indexes[-f]" should equal 4
    The variable "_orb_args_values_lengths[-f]" should equal 1
    The variable "dash[@]" should equal "some values come before"
    The variable flag should equal "some values after"
  End

  It 'should handle catch multiple'
    declare -a _orb_declared_catchs=('multiple')
    declare -A _orb_declared_catchs_start_indexes=([-f]=0)
    declare -A _orb_declared_catchs_lengths=([-f]=1)
    _orb_assign_arg_value -f "first value"
    When call _orb_assign_arg_value -f "second value"
    The variable "_orb_args_values_start_indexes[-f]" should equal "0 1"
    The variable "_orb_args_values_lengths[-f]" should equal "1 1"
    The variable "flag[@]" should equal "first value second value"
  End
End



# _orb_assign_boolean_flag
Describe '_orb_assign_boolean_flag'
  It 'should call nested functions'
    _orb_assign_arg_value() { spec_fns+=($(echo_fn $@)); }
    _orb_shift_args() { spec_fns+=($(echo_fn $@)); }
    When call _orb_assign_boolean_flag -f
    The variable "spec_fns[@]" should equal "_orb_assign_arg_value -f true _orb_shift_args 1"
  End

  It 'should assign true for - prefix'
    When call _orb_assign_boolean_flag -f
    The variable flag should equal true
  End

  It 'takes shift step override'
    _orb_shift_args() { spec_fns+=$(echo_fn $@); }
    When call _orb_assign_boolean_flag -f 0
    The variable "spec_fns[@]" should equal "_orb_shift_args 0"
  End
End

Describe '_orb_flag_value'
	It 'returns true if starts with -'
    When call _orb_flag_value -f
    The output should equal true
  End

	It 'returns false if does not start with -'
    When call _orb_flag_value +f
    The output should equal false
  End
End


# _orb_assign_flagged_arg
Describe '_orb_assign_flagged_arg'
  _orb_args_remaining=(-f followed by args)
  declare -A _orb_declared_arg_suffixes=([-f]=3)

  _orb_assign_arg_value() { spec_args+=($(echo_fn $@)); }
  _orb_raise_invalid_arg() { spec_args+=($(echo_fn $@)); }
  _orb_shift_args() { spec_args+=($(echo_fn $@)); }

	It 'returns true if starts with -'
    When call _orb_assign_flagged_arg -f
    The variable "spec_args[@]" should equal "_orb_assign_arg_value -f followed by args _orb_shift_args 4"
  End

  It 'takes shift step override'
    When call _orb_assign_boolean_flag -f 0
    The variable "spec_args[@]" should equal "_orb_assign_arg_value -f true _orb_shift_args 0"
  End
End

# _orb_assign_block
Describe '_orb_assign_block'
  _orb_args_remaining=(-b- followed by args -b-)

	It 'assigns when end block exists'
    _orb_assign_arg_value() { spec_args+=($(echo_fn $@)); }
    When call _orb_assign_block -b-
    The variable "spec_args[@]" should equal "_orb_assign_arg_value -b- followed by args"
  End
 
	It 'assigns to var'
    When call _orb_assign_block -b-
    The variable "block[@]" should equal "followed by args"
  End

  It 'raises error if end block missing'
    orb_raise_error() { spec_args+=($(echo_fn $@)); return 1; }
    _orb_args_remaining=(-b- followed by args)
    When call _orb_assign_block -b-
    The status should be failure
    The variable "spec_args[@]" should equal "orb_raise_error '-b-' missing block end"
  End
End

# _orb_assign_inline_arg
Describe '_orb_assign_inline_arg'
  _orb_args_count=1

  It 'calls nested functions with correct args'
    _orb_assign_arg_value() { spec_args+=($(echo_fn $@)); }
    _orb_shift_args() { spec_args+=($(echo_fn $@)); }
    When call _orb_assign_inline_arg val
    The variable "spec_args[@]" should equal "_orb_assign_arg_value 1 val _orb_shift_args"
    The variable "_orb_args_positional" should equal "val"
  End

  It 'assigns to _orb_arg_positional, declared value variable and increments count'
    When call _orb_assign_inline_arg val
    The variable "_orb_args_positional" should equal "val"
    The variable "one" should equal "val"
    The variable "_orb_args_count" should equal 2
  End
End

# _orb_assign_dash
Describe '_orb_assign_dash'
  _orb_args_remaining=(-- args remaining)

  It 'calls nested functions with correct args'
    _orb_args_remaining=(-- args remaining)
    _orb_assign_arg_value() { spec_args+=($(echo_fn $@)); }
    When call _orb_assign_dash
    The variable "spec_args[@]" should equal "_orb_assign_arg_value -- args remaining"
  End

  It 'assigns to declared value variable and empties remaining args'
    When call _orb_assign_dash
    The variable "dash[@]" should equal "args remaining"
    The variable "_orb_args_remaining[@]" should be undefined
  End
End

# _orb_assign_rest
Describe '_orb_assign_rest'
  _orb_args_remaining=(rest of args)

  It 'calls nested functions with correct args'
    _orb_assign_arg_value() { spec_args+=($(echo_fn $@)); }
    _orb_shift_args() { spec_args+=($(echo_fn $@)); }
    _orb_assign_dash() { spec_args+=($(echo_fn $@)); }
    When call _orb_assign_rest
    The variable "spec_args[@]" should equal "_orb_assign_arg_value ... rest of args"
  End

  It 'assigns to declared value variable and empties remaining args'
    When call _orb_assign_rest
    The variable "rest[@]" should equal "rest of args"
    The variable "dash[@]" should be undefined
    The variable "_orb_args_remaining[@]" should be undefined
  End

  Context 'with dash args included'
    _orb_args_remaining=(rest of args -- dash args)

    It 'calls nested functions with correct args'
      _orb_args_remaining=(rest of args -- dash args)
      _orb_assign_arg_value() { spec_args+=($(echo_fn $@)); }
      _orb_shift_args() { spec_args+=($(echo_fn $@)); }
      _orb_assign_dash() { spec_args+=($(echo_fn $@)); }
      When call _orb_assign_rest
      The variable "spec_args[@]" should equal "_orb_shift_args 3 _orb_assign_dash _orb_assign_arg_value ... rest of args"
    End

    It 'assigns to declared value variables and empties remaining args'
      When call _orb_assign_rest
      The variable "rest[@]" should equal "rest of args"
      The variable "dash[@]" should equal "dash args"
      The variable "_orb_args_remaining[@]" should be undefined
    End
  End
End

# _orb_shift_args
Describe '_orb_shift_args'
  _orb_args_remaining=(some args remaining)

  It 'shifts args in args remaining array'
    When call _orb_shift_args
    The variable "_orb_args_remaining[@]" should equal "args remaining"
  End

  It 'handles multiple steps'
    When call _orb_shift_args 2
    The variable "_orb_args_remaining[@]" should equal "remaining"
  End
End
