Include functions/declaration/function.sh
Include functions/declaration/function_options.sh
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
    _orb_get_declared_function_options() { spec_fns+=( $(echo_fn) );}
    _orb_get_declared_args() { spec_fns+=( $(echo_fn) );}
    _orb_parse_declared_function_options() { spec_fns+=( $(echo_fn) );}
    _orb_parse_declared_args() { spec_fns+=( $(echo_fn) );}

    It 'calls correctly'
      _orb_function_declaration=(1 = first)
      When call _orb_parse_function_declaration
      The variable "spec_fns[@]" should equal "_orb_prevalidate_declaration _orb_get_declared_function_options _orb_get_declared_args _orb_parse_declared_function_options _orb_parse_declared_args"
    End

    It 'does not parse args if $2 = false'
      When call _orb_parse_function_declaration _orb_function_declaration false
      The variable "spec_fns[@]" should equal "_orb_prevalidate_declaration _orb_get_declared_function_options _orb_get_declared_args _orb_parse_declared_function_options"
    End
  End

  It 'stores arguments and options to variables'
    _orb_function_declaration=(
      "Function comment"
      RawArgs: true

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
    The variable "_orb_declared_raw_args" should equal true
    The variable "_orb_declared_args[@]" should equal "1 -a"
    The variable "_orb_declared_comments[1]" should equal "This is first comment"
    The variable "_orb_declared_comments[-a]" should equal "This is flagged comment"

    The variable "_orb_declared_option_values[@]" should equal "false value first value or other true value second value or other"
    # alphabetic order from associative array options keys but still testable
    The variable "_orb_declared_option_start_indexes[@]" should equal "- - 2 8 - - 1 7 0 6"
    The variable "_orb_declared_option_lengths[@]" should equal "- - 4 4 - - 1 1 1 1"
  End
End

# _orb_get_declared_function_options
Describe '_orb_get_declared_function_options'
  declaration=(
    "Comment"
    RawArgs: true

    1 = first
  )

  It "gets declared function options"
    When call _orb_get_declared_function_options
    The variable "declared_function_options[0]" should equal "Comment"
    The variable "declared_function_options[@]" should equal "Comment RawArgs: true"
  End

  It 'gets declared function options when no args declared'
    declaration=(
      "Comment"
      RawArgs: true
    )

    When call _orb_get_declared_function_options
    The variable "declared_function_options[0]" should equal "Comment"
    The variable "declared_function_options[@]" should equal "Comment RawArgs: true"
  End
  
  It 'does not get function options when only args declared'
    declaration=(
      1 = first
    )

    When call _orb_get_declared_function_options
    The variable "declared_function_options[@]" should be undefined
  End
End

# _orb_get_declared_args
Describe '_orb_get_declared_args'
  declaration=(
    "Comment"
    RawArgs: true

    1 = first
  )

  It "gets declared args"
    _orb_get_declared_function_options
    When call _orb_get_declared_args
    The variable "declared_args[0]" should equal "1"
    The variable "declared_args[@]" should equal "1 = first"
  End

  It 'gets declared args when no function options declared'
    declaration=(
      1 = first
    )

    _orb_get_declared_function_options
    When call _orb_get_declared_args
    The variable "declared_args[0]" should equal "1"
    The variable "declared_args[@]" should equal "1 = first"
  End
End
