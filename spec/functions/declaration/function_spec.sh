Include functions/declaration/function.sh
Include functions/declaration/arguments.sh
Include functions/declaration/validation.sh
Include functions/declaration/checkers.sh
Include functions/declaration/getters.sh
Include functions/utils/argument.sh
Include functions/utils/utils.sh
Include scripts/call/variables.sh
Include scripts/initialize_variables.sh

# _orb_parse_declaration
Describe '_orb_parse_function_declaration'
  Include functions/declaration/argument_options.sh

  Context 'nested functions'
    _orb_prevalidate_declaration() { spec_fns+=( $(echo_fn) ); }
    _orb_parse_function_options() { spec_fns+=( $(echo_fn) );}
    _orb_parse_declared_args() { spec_fns+=( $(echo_fn) );}

    It 'calls correctly'
      When call _orb_parse_function_declaration
      The variable "spec_fns[@]" should equal "_orb_prevalidate_declaration _orb_parse_function_options _orb_parse_declared_args"
    End

    It 'does not parse args if $2 = false'
      When call _orb_parse_function_declaration _orb_function_declaration false
      The variable "spec_fns[@]" should equal "_orb_prevalidate_declaration _orb_parse_function_options"
    End
  End

  It 'stores arguments and options to variables'
    _orb_function_declaration=(
      "Function comment"
      DirectCall: true

      1 = first 
        "This is first comment"
        Required: false
        Default: value
        In: first value or other
      -a 1 = flagged_arg
        "This is flagged comment"
        Required: true
        Default: value
        In: second value or other
    )

    When call _orb_parse_function_declaration
    The variable "_orb_declared_comments[function]" should equal "Function comment"
    The variable "_orb_declared_direct_call" should equal true
    The variable "_orb_declared_args[@]" should equal "1 -a"
    The variable "_orb_declared_comments[1]" should equal "This is first comment"
    The variable "_orb_declared_comments[-a]" should equal "This is flagged comment"

    The variable "_orb_declared_option_values[@]" should equal "false value first value or other true value second value or other"
    The variable "_orb_declared_option_start_indexes[@]" should equal "- - 2 8 - - - - 1 7 0 6"
    The variable "_orb_declared_option_lengths[@]" should equal "- - 4 4 - - - - 1 1 1 1"
  End
End

# _orb_parse_function_options
Describe "_orb_parse_function_options"
  declaration=(
    "Function comment"

    1 = first
    -f = flag
  )

  _orb_declared_args=(1 -f)
  declare -A declared_args_start_indexes=([1]=1 [-f]=4)

  It 'Gets comment'
    When call _orb_parse_function_options
    The variable "_orb_declared_comments[function]" should equal "Function comment"
  End
End

# _orb_get_function_options
Describe '_orb_get_function_options'
  It 'extracts options array and stores comment from declaration'
    declaration=(
      "Function comment"
      DirectCall: true

      1 = "My first variable"
    )

    When call _orb_get_function_options
    The variable "declared_function_options[@]" should eq "DirectCall: true"
    The variable "_orb_declared_comments[function]" should eq "Function comment"
  End
End


# _orb_extract_function_comment
Describe "_orb_extract_function_comment"
  declared_function_options=(comment)

  It 'sets first fn option to comments'
    When call _orb_extract_function_comment
    The variable "_orb_declared_comments[function]" should equal "comment"
  End

  It 'fails if first is function option'
    declared_function_options=(DirectCall:)
    When call _orb_extract_function_comment
    The status should be failure
    The variable "_orb_declared_comments[function]" should be undefined
  End
End

# _orb_get_function_options_start_indexes
Describe "_orb_get_function_options_start_indexes"
  declared_function_options=(DirectCall: value DirectCall: value)

  It 'stores correct start_indexes'
    When call _orb_get_function_options_start_indexes
    The variable "declared_function_options_start_indexes[@]" should equal "0 2"
  End

  It 'raises on option as option value'
    declared_function_options=(DirectCall: DirectCall: value)
    _orb_raise_invalid_declaration() { echo_fn "$@"; }
    When call _orb_get_function_options_start_indexes
    The output should equal "_orb_raise_invalid_declaration DirectCall: invalid value: DirectCall:"
  End

  It 'raises on option without value'
    declared_function_options=(DirectCall: true DirectCall:)
    _orb_raise_invalid_declaration() { echo_fn "$@"; }
    When call _orb_get_function_options_start_indexes
    The output should equal "_orb_raise_invalid_declaration DirectCall: missing value"
  End
End

# _orb_get_function_options_lengths
Describe "_orb_get_function_options_start_indexes"
  declared_function_options=(DirectCall: value DirectCall: value)
  declared_function_options_start_indexes=(0 2)

  It 'stores correct lengths'
    When call _orb_get_function_options_lengths
    The variable "declared_function_options_lengths[@]" should equal "2 2"
  End
End

# _orb_store_function_options
Describe '_orb_store_function_options'
  declared_function_options=(DirectCall: true)
  declared_function_options_start_indexes=(0)
  declared_function_options_lengths=(2)

  It 'stores DirectCall:'
    When call _orb_store_function_options
    The variable "_orb_declared_direct_call" should eq true
  End
End
