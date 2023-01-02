Include functions/declaration/function_options.sh
Include functions/declaration/validation.sh
Include functions/utils/utils.sh
Include scripts/call/variables.sh
Include scripts/initialize_variables.sh

# _orb_parse_declared_function_options
Describe "_orb_parse_declared_function_options"
  It 'calls nested functions'
    _orb_extract_function_comment() { spec_fns+=( $(echo_fn) ); }
    _orb_prevalidate_declared_function_options() { spec_fns+=( $(echo_fn) );}
    _orb_get_function_options_start_indexes() { spec_fns+=( $(echo_fn) );}
    _orb_get_function_options_lengths() { spec_fns+=( $(echo_fn) );}
    _orb_store_function_options() { spec_fns+=( $(echo_fn) );}
    _orb_postvalidate_declared_function_options() { spec_fns+=( $(echo_fn) );}

    When call _orb_parse_declared_function_options
    The variable "spec_fns[@]" should equal "_orb_extract_function_comment _orb_prevalidate_declared_function_options _orb_get_function_options_start_indexes _orb_get_function_options_lengths _orb_store_function_options _orb_postvalidate_declared_function_options"
  End


  It 'Gets comment'
    declared_function_options=(
      "Function comment"
      RawArgs: true
    )

    When call _orb_parse_declared_function_options
    The variable "_orb_declared_comments[function]" should equal "Function comment"
  End
End

# _orb_extract_function_comment
Describe "_orb_extract_function_comment"
  declaration=(comment)

  It 'sets first fn option to comments'
    When call _orb_extract_function_comment
    The variable "_orb_declared_comments[function]" should equal "comment"
  End

  It 'fails if first is function option'
    declaration=(RawArgs:)
    When call _orb_extract_function_comment
    The status should be failure
    The variable "_orb_declared_comments[function]" should be undefined
  End
End

# _orb_get_function_options_start_indexes
Describe "_orb_get_function_options_start_indexes"
  declaration=(RawArgs: value RawArgs: value)

  It 'stores correct start_indexes'
    When call _orb_get_function_options_start_indexes
    The variable "declared_function_options_start_indexes[@]" should equal "0 2"
  End

  It 'raises on option as option value'
    declaration=(RawArgs: RawArgs: value)
    _orb_raise_invalid_declaration() { echo_fn "$@"; }
    When call _orb_get_function_options_start_indexes
    The output should equal "_orb_raise_invalid_declaration RawArgs: invalid value: RawArgs:"
  End

  It 'raises on option without value'
    declaration=(RawArgs: true RawArgs:)
    _orb_raise_invalid_declaration() { echo_fn "$@"; }
    When call _orb_get_function_options_start_indexes
    The output should equal "_orb_raise_invalid_declaration RawArgs: missing value"
  End
End

# _orb_get_function_options_lengths
Describe "_orb_get_function_options_start_indexes"
  declaration=(RawArgs: value RawArgs: value)
  declared_function_options_start_indexes=(0 2)

  It 'stores correct lengths'
    When call _orb_get_function_options_lengths
    The variable "declared_function_options_lengths[@]" should equal "2 2"
  End
End

# _orb_store_function_options
Describe '_orb_store_function_options'
  declaration=(RawArgs: true)
  declared_function_options_start_indexes=(0)
  declared_function_options_lengths=(2)

  It 'stores RawArgs:'
    When call _orb_store_function_options
    The variable "_orb_declared_raw_args" should eq true
  End
End
