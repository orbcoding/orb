Include functions/declaration/validation.sh
Include functions/declaration/checkers.sh
Include functions/declaration/getters.sh
Include scripts/call/variables.sh
Include functions/utils/argument.sh
Include functions/help.sh

# _orb_prevalidate_declaration
Describe '_orb_prevalidate_declaration'
  raise_invalid_declaration() { echo "$@"; }

  declaration=(= value)

  It 'raises invalid declaration if starts with ='
    When call _orb_prevalidate_declaration
    The output should equal "Cannot start with ="
  End
End

# _orb_raise_invalid_declaration
Describe '_orb_raise_invalid_declaration'
  orb_raise_error() { echo "$@"; }

  It 'calls raise error with invalid declaration error'
    When call _orb_raise_invalid_declaration "error message"
    The output should equal "Invalid declaration. error message"
  End
End

# _orb_raise_undeclared
Describe '_orb_raise_undeclared'
  orb_raise_error() { echo "$@"; }

  It 'calls raise error with undeclared error'
    # When call _orb_raise_undeclared "1"
    # The output should equal "'1' not in args declaration"
  End
End


# _orb_postvalidate_declared_args_options
Describe '_orb_postvalidate_declared_args_options'
  It 'calls _orb_postvalidate_declared_args_options_catchs'
    _orb_postvalidate_declared_args_options_catchs() { spec_args+=$(echo_fn); }
    _orb_postvalidate_declared_args_options_requireds() { spec_args+=$(echo_fn); }
    _orb_postvalidate_declared_args_options_multiples() { spec_args+=$(echo_fn); }
    _orb_postvalidate_declared_args_incompatible_options() { spec_args+=$(echo_fn); }
    
    When call _orb_postvalidate_declared_args_options
    The status should be success
    The variable "spec_args[@]" should equal "_orb_postvalidate_declared_args_options_catchs_orb_postvalidate_declared_args_options_requireds_orb_postvalidate_declared_args_options_multiples_orb_postvalidate_declared_args_incompatible_options"
  End
End


# _orb_postvalidate_declared_args_options_catchs
Describe '_orb_postvalidate_declared_args_options_catchs'
  _orb_declared_args=(-f)
  declare -a _orb_declared_catchs=(1 flag block dash 2)
  declare -A _orb_declared_catchs_start_indexes=([-f]=1)
  declare -A _orb_declared_catchs_lengths=([-f]=3)

  It 'succeeds on valid catch values'
    When call _orb_postvalidate_declared_args_options_catchs
    The status should be success
  End

  It 'fails on invalid catch values'
    _orb_raise_invalid_declaration() { echo_fn $@; exit 1; }
    declare -A _orb_declared_catchs_start_indexes=([-f]=0)
    When run _orb_postvalidate_declared_args_options_catchs
    The status should be failure
    The output should equal "_orb_raise_invalid_declaration -f: Invalid Catch: value: 1. Available values: any flag block dash"
  End
End

# _orb_postvalidate_declared_args_options_requireds
Describe '_orb_postvalidate_declared_args_options_requireds'
  _orb_declared_args=(-f)
  declare -A _orb_declared_requireds=([-f]=true)

  It 'succeeds on valid required values'
    When call _orb_postvalidate_declared_args_options_requireds
    The status should be success
  End

  It 'fails on invalid required values'
    _orb_raise_invalid_declaration() { echo_fn $@; exit 1; }
    declare -A _orb_declared_requireds=([-f]=asd)
    When run _orb_postvalidate_declared_args_options_requireds
    The status should be failure
    The output should equal "_orb_raise_invalid_declaration -f: Invalid Required: value: asd. Available values: true false"
  End
End

# _orb_postvalidate_declared_args_options_multiples
Describe '_orb_postvalidate_declared_args_options_multiples'
  _orb_declared_args=(-f)
  declare -A _orb_declared_multiples=([-f]=true)

  It 'succeeds on valid multiple values'
    When call _orb_postvalidate_declared_args_options_multiples
    The status should be success
  End

  It 'fails on invalid multiple values'
    _orb_raise_invalid_declaration() { echo_fn $@; exit 1; }
    declare -A _orb_declared_multiples=([-f]=asd)
    When run _orb_postvalidate_declared_args_options_multiples
    The status should be failure
    The output should equal "_orb_raise_invalid_declaration -f: Invalid Multiple: value: asd. Available values: true false"
  End
End

# _orb_postvalidate_declared_args_incompatible_options
Describe '_orb_postvalidate_declared_args_incompatible_options'
  _orb_declared_args=(-f)
  declare -A _orb_declared_defaults_start_indexes=([-f]=0)

  It 'succeeds on valid multiple values'
    When call _orb_postvalidate_declared_args_incompatible_options
    The status should be success
  End

  It 'fails on invalid multiple values'
    _orb_raise_invalid_declaration() { echo_fn $@; exit 1; }
    declare -A _orb_declared_default_evals=([-f]=val)
    When run _orb_postvalidate_declared_args_incompatible_options
    The status should be failure
    The output should equal "_orb_raise_invalid_declaration -f: Incompatible options: Default:, DefaultEval:"
  End
End

# _orb_is_valid_arg_option
Describe '_orb_is_valid_arg_option'
  _orb_raise_invalid_declaration() { echo "$@"; return 1; }
  declare -A _orb_declared_arg_suffixes

  Context 'with number args'
    It 'succeeds for Required:'
      When call _orb_is_valid_arg_option 1 Default:
      The status should be success
    End

    It 'fails for Multiple:'
      When call _orb_is_valid_arg_option 1 Multiple:
      The status should be failure
      The output should equal "1: Invalid option: Multiple:. Available options for number args: Required: Default: DefaultEval: In:"
    End
  End

  Context 'with boolean flags'
    _orb_declared_args=(-f)

    It 'succeeds for Required:'
      When call _orb_is_valid_arg_option -f Default:
      The status should be success
    End

    It 'fails for Multiple:'
      When call _orb_is_valid_arg_option -f Multiple:
      The status should be failure
      The output should equal "-f: Invalid option: Multiple:. Available options for boolean flags: Required: Default: DefaultEval:"
    End
  End

  Context 'with flag args'
    _orb_declared_args=(-f)
    declare -A _orb_declared_arg_suffixes=([-f]=1)

    It 'succeeds for In:'
      When call _orb_is_valid_arg_option -f In:
      The status should be success
    End

    It 'fails for Catch:'
      When call _orb_is_valid_arg_option -f Catch:
      The status should be failure
      The output should equal "-f: Invalid option: Catch:. Available options for flag args: Required: Default: DefaultEval: Multiple: In:"
    End
  End

  Context 'with array flag args'
    declare -A _orb_declared_arg_suffixes=([-f]=2)

    It 'succeeds for Required:'
      When call _orb_is_valid_arg_option -f Required:
      The status should be success
    End

    It 'fails for In:'
      When call _orb_is_valid_arg_option -f In:
      The status should be failure
      The output should equal "-f: Invalid option: In:. Available options for flag array args: Required: Default: DefaultEval: Multiple:"
    End
  End

  Context 'with block'
    It 'succeeds for Multiple:'
      When call _orb_is_valid_arg_option -f- Multiple:
      The status should be success
    End

    It 'fails for In:'
      When call _orb_is_valid_arg_option -f- In:
      The status should be failure
      The output should equal "-f-: Invalid option: In:. Available options for blocks: Required: Default: DefaultEval: Multiple:"
    End
  End

  Context 'with dash'
    It 'succeeds for Required:'
      When call _orb_is_valid_arg_option -- Required:
      The status should be success
    End

    It 'fails for In:'
      When call _orb_is_valid_arg_option -- In:
      The status should be failure
      The output should equal "--: Invalid option: In:. Available options for --: Required: Default: DefaultEval:"
    End
  End

  Context 'with rest'
    It 'succeeds for Required:'
      When call _orb_is_valid_arg_option ... Required:
      The status should be success
    End

    It 'fails for In:'
      When call _orb_is_valid_arg_option ... In:
      The status should be failure
      The output should equal "...: Invalid option: In:. Available options for ...: Required: Default: DefaultEval: Catch:"
    End
  End
End
