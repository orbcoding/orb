Include functions/declaration/function.sh
Include functions/declaration/arguments.sh
Include functions/declaration/validation.sh
Include functions/declaration/checkers.sh
Include functions/declaration/getters.sh
Include functions/utils/argument.sh
Include scripts/call/variables.sh

# _orb_parse_declaration
Describe '_orb_parse_function_declaration'
  Include functions/declaration/argument_options.sh

  It 'calls its nested functions'
    _orb_prevalidate_declaration() { spec_fns+=( $(echo_fn) ); }
    _orb_parse_declared_args() { spec_fns+=( $(echo_fn) ); }
    _orb_parse_function_options() { spec_fns+=( $(echo_fn) );}
    When call _orb_parse_function_declaration
    The variable "spec_fns[@]" should equal "_orb_prevalidate_declaration _orb_parse_declared_args _orb_parse_function_options"
  End

  It 'stores arguments and options to variables'
    _orb_function_declaration=(
      "Function comment"

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
    The variable "_orb_declared_args[@]" should equal "1 -a"

    The variable "_orb_declared_requireds[1]" should equal "false"
    The variable "_orb_declared_comments[1]" should equal "This is first comment"
    The variable "_orb_declared_defaults_start_indexes[1]" should equal "0"
    The variable "_orb_declared_defaults_lengths[1]" should equal "1"
    The variable "_orb_declared_ins_start_indexes[1]" should equal "0"
    The variable "_orb_declared_ins_lengths[1]" should equal "4"
    
    The variable "_orb_declared_requireds[-a]" should equal "true"
    The variable "_orb_declared_comments[-a]" should equal "This is flagged comment"
    The variable "_orb_declared_defaults_start_indexes[-a]" should equal "1"
    The variable "_orb_declared_defaults_lengths[-a]" should equal "1"
    The variable "_orb_declared_ins_start_indexes[-a]" should equal "4"
    The variable "_orb_declared_ins_lengths[-a]" should equal "4"
    
    The variable "_orb_declared_ins[@]" should equal "first value or other second value or other"
    The variable "_orb_declared_defaults[@]" should equal "value value"
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

# _orb_extract_function_comment
Describe "_orb_extract_function_comment"
  options=(comment)

  It 'sets first fn option to comments'
    When call _orb_extract_function_comment
    The variable "_orb_declared_comments[function]" should equal "comment"
  End
End
