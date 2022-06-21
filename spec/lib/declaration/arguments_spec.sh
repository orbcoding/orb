Include lib/utils/argument.sh
# Include lib/utils/utils.sh
Include lib/declaration/arguments.sh
Include lib/helpers/declaration/general.sh

# _orb_declaration=("${spec_orb_declaration[@]}")
_orb_declaration=(
  flag = -f
  flagged_arg = -a 1
    Required: true
  verbose_flag = --verbose-flag 
  verbose_flagged_arg = --verbose-flagged 1 
  block = -b- # i = 16-18
  dash_args = --  
  rest = ... 
    Required: false
)

# _orb_declared_args=(
#   -q "-w 1" --verbose-flag -b- @ --
# )
# _orb_caller_args_declared=(
#   -a
# )

# _orb_parse_declaration
Describe '_orb_parse_declaration'
  Include lib/declaration/argument_options.sh
  Include lib/helpers/declaration/argument_options.sh

  It 'calls its nested functions'
    _orb_prevalidate_declaration() { spec_fns+=( $(echo_me) ); }
    _orb_parse_declared_args() { spec_fns+=( $(echo_me) ); }
    _orb_parse_args_options_declaration() { spec_fns+=( $(echo_me) ); }
    When call _orb_parse_declaration
    The variable "spec_fns[@]" should equal "_orb_prevalidate_declaration _orb_parse_declared_args _orb_parse_args_options_declaration"
  End

  It 'stores arguments and options to variables'
    _orb_declaration=(
      first = 1
        Required: false
        Comment: "This is first comment"
        Default: value
        In: first value or other
      flagged_arg = -a 1
        Required: true
        Comment: "This is flagged comment"
        Default: value
        In: second value or other
    )

    When call _orb_parse_declaration
    The variable "_orb_declared_args[@]" should equal "1 -a"
    The variable "_orb_declared_requireds[@]" should equal "false true"
    The variable "_orb_declared_comments[@]" should equal "This is first comment This is flagged comment"
    The variable "_orb_declared_defaults[@]" should equal "value value"
    The variable "_orb_declared_defaults_indexes[@]" should equal "0 1"
    The variable "_orb_declared_defaults_lengths[@]" should equal "1 1"
    The variable "_orb_declared_ins[@]" should equal "first value or other second value or other"
    The variable "_orb_declared_ins_indexes[@]" should equal "0 4"
    The variable "_orb_declared_ins_lengths[@]" should equal "4 4"
  End
End

# _orb_get_arg_declaration_arg_indexes
Describe '_orb_get_arg_declaration_arg_indexes'
  arg_declaration_arg_indexes=()

  It 'stores indexes in arg_declaration_arg_indexes array'
    When call _orb_get_arg_declaration_arg_indexes
    The status should be success
    The variable "arg_declaration_arg_indexes[@]" should equal "0 3 9 12 16 19 22"
  End
End

# _orb_is_arg_declaration_index
Describe '_orb_is_arg_declaration_index'
  It 'succeeds if first is variable name and third is input_arg'
    When call _orb_is_arg_declaration_index 0
    The status should be success
  End

  It 'fails if first is not valid variable'
    _orb_declaration=( 12 = -f )
    When call _orb_is_arg_declaration_index 0
    The status should be failure
  End

  It 'fails if third is not valid input_arg'
    _orb_declaration=( var = _f )
    When call _orb_is_arg_declaration_index 0
    The status should be failure
  End
End

# _orb_get_arg_declaration_arg_lengths
Describe '_orb_get_arg_declaration_arg_lengths'
  arg_declaration_arg_indexes=( 0 3 9 12 16 19 22 )

  It 'stores length in arg_declaration_arg_lengths array'
    When call _orb_get_arg_declaration_arg_lengths
    The status should be success
    The variable "arg_declaration_arg_lengths[@]" should equal "3 6 3 4 3 3 5"
  End
End


# _orb_parse_declared_args
Describe '_orb_parse_declared_args'
  It 'calls its functions'
    _orb_get_arg_declaration_arg_indexes() { spec_fns+=( $(echo_me) ); }
    _orb_get_arg_declaration_arg_lengths() { spec_fns+=( $(echo_me) ); }
    _orb_store_declared_args() { spec_fns+=( $(echo_me) ); }
    When call _orb_parse_declared_args
    The status should be success
    The variable 'spec_fns[@]' should equal "_orb_get_arg_declaration_arg_indexes _orb_get_arg_declaration_arg_lengths _orb_store_declared_args"
  End
End

# _orb_store_declared_args
Describe '_orb_store_declared_args'
  arg_declaration_arg_indexes=( 0 3 9 12 16 19 22 )

  It 'stores variables to _orb_declared_vars'
    When call _orb_store_declared_args
    The variable "_orb_declared_vars[@]" should equal "flag flagged_arg verbose_flag verbose_flagged_arg block dash_args rest"
  End

  It 'stores arguments to _orb_declared_args'
    When call _orb_store_declared_args
    The variable "_orb_declared_args[@]" should equal "-f -a --verbose-flag --verbose-flagged -b- -- ..."
  End
End

