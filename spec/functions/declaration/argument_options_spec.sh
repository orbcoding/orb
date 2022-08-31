Include functions/utils/argument.sh
Include functions/declaration/argument_options.sh
Include functions/declaration/validation.sh
Include functions/declaration/checkers.sh
Include functions/declaration/getters.sh
Include scripts/call/variables.sh

_orb_declared_args=(1 -a)

# As set in _orb_parse_declaration
declaration=(
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

declare -A declared_args_start_indexes=([1]="0" [-a]="13")
declare -A declared_args_lengths=([1]="13" [-a]="14")
declare -A _orb_declared_arg_suffixes=([-a]="1")


# _orb_parse_declared_args_options
Describe '_orb_parse_declared_args_options'

  Context 'calls nested functions with parameters'
    _orb_set_declared_arg_options_defaults() { spec_args+=($(echo_fn "$@")); }
    _orb_parse_declared_arg_options() { spec_args+=($(echo_fn "$@")); }
    _orb_prevalidate_declared_arg_options() { spec_args+=($(echo_fn "$@")); }
    _orb_postvalidate_declared_args_options() { spec_args+=($(echo_fn "$@")); }

    It 'prevalidates and parses if options found'
      _orb_get_declared_arg_options() { spec_args+=($(echo_fn "$@")); declared_arg_options=(opt); }
      When call _orb_parse_declared_args_options
      The variable "spec_args[@]" should equal "\
_orb_set_declared_arg_options_defaults 1 \
_orb_get_declared_arg_options 1 \
_orb_prevalidate_declared_arg_options 1 \
_orb_parse_declared_arg_options 1 \
\
_orb_set_declared_arg_options_defaults -a \
_orb_get_declared_arg_options -a \
_orb_prevalidate_declared_arg_options -a \
_orb_parse_declared_arg_options -a \
_orb_postvalidate_declared_args_options"
    End

    It "doesnt prevalidate or parse if no options found"
      _orb_get_declared_arg_options() { spec_args+=($(echo_fn "$@"));}
      When call _orb_parse_declared_args_options
      The variable "spec_args[@]" should equal "\
_orb_set_declared_arg_options_defaults 1 \
_orb_get_declared_arg_options 1 \
\
_orb_set_declared_arg_options_defaults -a \
_orb_get_declared_arg_options -a \
_orb_postvalidate_declared_args_options"
    End 
  End

  Context 'holistic testing'
    It 'stores options to variables'
      When call _orb_parse_declared_args_options
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
End

# _orb_set_declared_arg_options_defaults
Describe '_orb_set_declared_arg_options_defaults'
  _orb_declared_args=(-f 1 --verbose-flag)

  It 'sets multiple = false'
    When call _orb_set_declared_arg_options_defaults -f
    The variable "_orb_declared_multiples[-f]" should equal false
  End

  It 'sets required = false for flags'
    When call _orb_set_declared_arg_options_defaults -f
    The variable "_orb_declared_requireds[-f]" should equal false
  End

  It 'sets required = true for other'
    When call _orb_set_declared_arg_options_defaults 1
    The variable "_orb_declared_requireds[1]" should equal true
  End
End

# _orb_get_declared_arg_options
Describe '_orb_get_declared_arg_options'
  It "calls _orb_store_declared_arg_comment"
    _orb_store_declared_arg_comment() { echo_fn "$@"; }
    When call _orb_get_declared_arg_options 1
    The output should equal "_orb_store_declared_arg_comment 1 3"
  End

  It 'gets options declaration and comment'
    When call _orb_get_declared_arg_options 1
    The variable "declared_arg_options[@]" should equal "Required: false Default: value In: first value or other"
    The variable "_orb_declared_comments[1]" should equal "This is first comment"
  End

  It 'gets options declaration with suffixed'
    When call _orb_get_declared_arg_options -a
    The variable "declared_arg_options[@]" should equal "Required: true Default: value In: second value or other"
    The variable "_orb_declared_comments[-a]" should equal "This is flagged comment"
  End

  It 'does not offset comment if extraction falsy'
    _orb_store_declared_arg_comment() { return 1; }
    When call _orb_get_declared_arg_options -a
    The variable "declared_arg_options[@]" should equal "This is flagged comment Required: true Default: value In: second value or other"
  End

  It 'does not set declared_arg_options if there are none'
    declaration=(1 = first)
    When call _orb_get_declared_arg_options 1
    The variable "declared_arg_options[@]" should be undefined
  End

  It 'does not set declared_arg_options if there is only a comment'
    declaration=(1 = first "comment of first")
    When call _orb_get_declared_arg_options 1
    The variable "declared_arg_options[@]" should be undefined
    The variable "_orb_declared_comments[1]" should equal "comment of first"
  End
End

# _orb_extract_arg_comment
Describe '_orb_extract_arg_comment'
  It 'stores comment if available'
    When call _orb_store_declared_arg_comment 1 3
    The variable "_orb_declared_comments[1]" should equal "This is first comment"
  End

  It 'fails if no comment available'
    declare -A declared_args_lengths=([1]="3")
    When call _orb_store_declared_arg_comment 1 3 
    The status should be failure
  End

  It 'fails if first string is valid option'
    declaration=(1 = first Default: true)
    declare -A declared_args_lengths=([1]="5")
    When call _orb_store_declared_arg_comment 1 3 
    The status should be failure
  End
End

# _orb_prevalidate_declared_arg_options
Describe '_orb_prevalidate_declared_arg_options'
  _orb_raise_invalid_declaration() { echo "$@"; return 1; }

  It 'should raise invalid declaration if first option str is not valid option'
    declared_arg_options=(invalid option)
    _orb_declared_args=(-f)

    When call _orb_prevalidate_declared_arg_options -f
    The status should be failure
    The output should equal "-f: Invalid option: invalid. Available options: Required: Default: In: Catch: Multiple: DefaultEval:"
  End

  It 'should not raise anything if first is valid option'
    declared_arg_options=(Required: true)
    _orb_declared_args=(-f)

    When call _orb_prevalidate_declared_arg_options 0
    The status should be success
  End
End


# _orb_parse_declared_arg_options
Describe '_orb_parse_declared_arg_options'
  Context 'testing internal calls'
    _orb_get_declared_arg_options_start_indexes() { :; }
    _orb_get_declared_arg_options_lengths() { :; }
    _orb_store_declared_arg_options() { :; }


    It 'calls correct functions with arg'
      _orb_get_declared_arg_options_start_indexes() { spec_args+=("$@"); }
      _orb_get_declared_arg_options_lengths() { spec_args+=("$@"); }
      _orb_store_declared_arg_options() { spec_args+=("$@"); }
      When call _orb_parse_declared_arg_options 1
      The variable "spec_args[@]" should equal "1 1 1"
    End
  End
End


Describe '_orb_get_declared_arg_options_start_indexes'
  _orb_raise_invalid_declaration() { echo "$@"; exit 1; }

  It 'calls _orb_is_declared_arg_options_start_index with arg and option_i'
    declared_arg_options=(
      Default: value 
      Required: true
    )
    _orb_is_declared_arg_options_start_index() { spec_args+=("$@,");}
    When call _orb_get_declared_arg_options_start_indexes 1
    The variable "spec_args[@]" should equal "1 0, 1 1, 1 2, 1 3,"
  End

  It 'add option indexes to declared_arg_options_start_indexes'
    declared_arg_options=(
      Default: value 
      Required: true
    )
    _orb_declared_args=(-f)

    When call _orb_get_declared_arg_options_start_indexes 1
    The variable "declared_arg_options_start_indexes[@]" should equal "0 2"
  End
  
  It 'handles flagged args'
    declared_arg_options=(
      Default: spec 
      Required: true
      In: spec
    )
    _orb_declared_args=(-f)
    _orb_declared_arg_suffixes=(1)

    When call _orb_get_declared_arg_options_start_indexes 1
    The variable "declared_arg_options_start_indexes[@]" should equal "0 2 4"
  End

  It 'handles array input'
    declared_arg_options=(
      Default: spec multi line arr 
      Required: true
    )
    _orb_declared_args=(...)

    When call _orb_get_declared_arg_options_start_indexes 1
    The variable "declared_arg_options_start_indexes[@]" should equal "0 5"
  End
  
  It 'raises if option at end of declaration'
    declared_arg_options=(
      Required: 
    )
    _orb_declared_args=(1)
    When run _orb_get_declared_arg_options_start_indexes 1
    The status should be failure
    The output should equal "Required: missing value"
  End

  It 'raises if non_catch_all option before another option'
    declared_arg_options=(
      Required: Default: 
    )
    _orb_declared_args=(1)
    When run _orb_get_declared_arg_options_start_indexes 1
    The status should be failure
    The output should equal "Required: invalid value: Default:"
  End
End


# _orb_is_declared_arg_options_start_index
Describe '_orb_is_declared_arg_options_start_index'
  declared_arg_options=(
    In: value
    Required: true
  )
  # Mostly holistically tested by _orb_get_declared_arg_options_start_indexes
  It 'succeeds for valid option indexes'
    When call _orb_is_declared_arg_options_start_index 1 0
    The status should be success
  End

  It 'fails on non option indexes'
    _orb_declared_args=(1)
    When call _orb_is_declared_arg_options_start_index 1 1
    The status should be failure
  End
End


# _orb_get_declared_arg_options_lengths
Describe '_orb_get_declared_arg_options_lengths'
  declared_arg_options=(
    Default: Default values
    : "Value"
    Required: true
  )
  declared_arg_options_start_indexes=(0 3 5)
  declared_arg_options_lengths=()

  It 'stores length of options in declared_arg_options_lengths array'
    When call _orb_get_declared_arg_options_lengths
    The variable "declared_arg_options_lengths[@]" should equal "3 2 2"
  End
End



# _orb_store_declared_arg_options
Describe '_orb_store_declared_arg_options'
  _orb_declared_args=(...)

  declared_arg_options=(
    Default: some value
    In: value or other
    Required: true
    Catch: flag block
    Multiple: true
  )

  declared_arg_options_start_indexes=(0 3 7 9 12)
  declared_arg_options_lengths=(3 4 2 3 2)
  _orb_set_declared_arg_options_defaults ...

  It 'stores options to variables'
    When call _orb_store_declared_arg_options ...
    The variable "_orb_declared_requireds[...]" should equal true
    The variable "_orb_declared_defaults[@]" should equal "some value"
    The variable "_orb_declared_defaults_start_indexes[...]" should equal "0"
    The variable "_orb_declared_defaults_lengths[...]" should equal "2"
    The variable "_orb_declared_ins[@]" should equal "value or other"
    The variable "_orb_declared_ins_start_indexes[...]" should equal "0"
    The variable "_orb_declared_ins_lengths[...]" should equal "3"
    The variable "_orb_declared_catchs[@]" should equal "flag block"
    The variable "_orb_declared_catchs_start_indexes[...]" should equal "0"
    The variable "_orb_declared_catchs_lengths[...]" should equal "2"
    The variable "_orb_declared_multiples[...]" should equal "true"
  End
End
