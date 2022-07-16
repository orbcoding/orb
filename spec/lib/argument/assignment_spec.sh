Include lib/arguments/assignment.sh
Include lib/arguments/validation.sh
Include lib/scripts/call/variables.sh
Include lib/declaration/checkers.sh
Include lib/utils/argument.sh

declare flag
declare dash
declare -A _orb_declared_vars=([-f]=flag [--]=dash [-b-]=block)

Describe '_orb_assign_arg_value'
  It 'should assign to arg values arrs'
    _orb_assign_arg_value -- some values come before
    When call _orb_assign_arg_value -f some values after
    The variable "_orb_args_values[@]" should equal "some values come before some values after"
    The variable "_orb_args_values_start_indexes[--]" should equal 0
    The variable "_orb_args_values_lengths[--]" should equal 4
    The variable "_orb_args_values_start_indexes[-f]" should equal 4
    The variable "_orb_args_values_lengths[-f]" should equal 3
    The variable "dash[@]" should equal "some values come before"
    The variable flag should equal "some values after"
  End
End

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
  args_remaining=(-f followed by args)
  declare -A _orb_declared_arg_suffixes=([-f]=3)

  _orb_assign_arg_value() { spec_args+=($(echo_fn $@)); }
  _orb_raise_invalid_arg() { spec_args+=($(echo_fn $@)); }
  _orb_shift_args() { spec_args+=($(echo_fn $@)); }

	It 'returns true if starts with -'
    When call _orb_assign_flagged_arg -f
    The variable "spec_args[@]" should equal "_orb_assign_arg_value -f followed by args _orb_shift_args 3"
  End

  It 'takes shift step override'
    When call _orb_assign_boolean_flag -f 0
    The variable "spec_args[@]" should equal "_orb_assign_arg_value -f true _orb_shift_args 0"
  End
End

# _orb_assign_block
Describe '_orb_assign_block'
  args_remaining=(-b- followed by args -b-)

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
    args_remaining=(-b- followed by args)
    When call _orb_assign_block -b-
    The status should be failure
    The variable "spec_args[@]" should equal "orb_raise_error '-b-' missing block end"
  End
End


# TODO TODO CONTINUE
