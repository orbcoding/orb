Include functions/utils/argument.sh
Include functions/utils/utils.sh
Include functions/declaration/argument_options.sh
Include functions/declaration/validation.sh
Include functions/declaration/checkers.sh
Include functions/declaration/getters.sh
Include scripts/call/variables.sh
Include scripts/initialize_variables.sh

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
    _orb_parse_declared_arg_options() { spec_args+=($(echo_fn "$@")); }
    _orb_prevalidate_declared_arg_options() { spec_args+=($(echo_fn "$@")); }
    _orb_postvalidate_declared_args_options() { spec_args+=($(echo_fn "$@")); }

    It 'prevalidates and parses if options found'
      _orb_get_arg_options_declaration() { spec_args+=($(echo_fn "$@")); arg_options_declaration=(opt); }
      When call _orb_parse_declared_args_options
      The variable "spec_args[@]" should equal "\
_orb_get_arg_options_declaration 1 \
_orb_prevalidate_declared_arg_options 1 \
_orb_parse_declared_arg_options 1 \
\
_orb_get_arg_options_declaration -a \
_orb_prevalidate_declared_arg_options -a \
_orb_parse_declared_arg_options -a \
_orb_postvalidate_declared_args_options"
    End
  End

  Context 'holistic testing'
    It 'stores options to variables'
      When call _orb_parse_declared_args_options

      The variable "_orb_declared_option_values[@]" should eq "false value first value or other true value second value or other"
      The variable "_orb_declared_option_start_indexes[Required:]" should eq "0 6"
      The variable "_orb_declared_option_lengths[Required:]" should eq "1 1"
      The variable "_orb_declared_option_start_indexes[In:]" should eq "2 8"
      The variable "_orb_declared_option_lengths[In:]" should eq "4 4"
    End
  End
End

# _orb_set_declared_arg_options_defaults
# Describe '_orb_set_declared_arg_options_defaults'
#   _orb_declared_args=(-f 1 --verbose-flag)

#   It 'sets required = false for flags'
#     When call _orb_set_declared_arg_options_defaults -f
#     The variable "_orb_declared_requireds[-f]" should equal false
#   End

#   It 'sets required = true for other'
#     When call _orb_set_declared_arg_options_defaults 1
#     The variable "_orb_declared_requireds[1]" should equal true
#   End
# End

# _orb_get_arg_options_declaration
Describe '_orb_get_declared_arg_options'
  It "calls _orb_store_declared_arg_comment"
    _orb_store_declared_arg_comment() { echo_fn "$@"; }
    When call _orb_get_arg_options_declaration 1
    The output should equal "_orb_store_declared_arg_comment 1 3"
  End

  It 'gets options declaration and comment'
    When call _orb_get_arg_options_declaration 1
    The variable "arg_options_declaration[@]" should equal "Required: false Default: value In: first value or other"
    The variable "_orb_declared_comments[1]" should equal "This is first comment"
  End

  It 'gets options declaration with suffixed'
    When call _orb_get_arg_options_declaration -a
    The variable "arg_options_declaration[@]" should equal "Required: true Default: value In: second value or other"
    The variable "_orb_declared_comments[-a]" should equal "This is flagged comment"
  End

  It 'does not offset comment if extraction falsy'
    _orb_store_declared_arg_comment() { return 1; }
    When call _orb_get_arg_options_declaration -a
    The variable "arg_options_declaration[@]" should equal "This is flagged comment Required: true Default: value In: second value or other"
  End

  It 'does not set arg_options_declaration if there are none'
    declaration=(1 = first)
    declare -A declared_args_start_indexes=([1]="0")
    declare -A declared_args_lengths=([1]="3")
    When call _orb_get_arg_options_declaration 1
    The variable "arg_options_declaration[@]" should be undefined
  End

  It 'does not set arg_options_declaration if there is only a comment'
    declaration=(1 = first "comment of first")
    declare -A declared_args_start_indexes=([1]="0")
    declare -A declared_args_lengths=([1]="4")
    When call _orb_get_arg_options_declaration 1
    The variable "arg_options_declaration[@]" should be undefined
    The variable "_orb_declared_comments[1]" should equal "comment of first"
  End
End

# _orb_store_declared_arg_comment
Describe '_orb_store_declared_arg_comment'
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
    arg_options_declaration=(invalid option)
    _orb_declared_args=(-f)

    When call _orb_prevalidate_declared_arg_options -f
    The status should be failure
    The output should equal "-f: Invalid option: invalid. Available options for boolean flags: Required: Default: DefaultHelp:"
  End

  It 'should not raise anything if first is valid option'
    arg_options_declaration=(Required: true)
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
    _orb_store_declared_arg_option_values() { :; }


    It 'calls correct functions with arg'
      _orb_get_declared_arg_options_start_indexes() { spec_args+=("$@"); }
      _orb_get_declared_arg_options_lengths() { spec_args+=("$@"); }
      _orb_store_declared_arg_option_values() { spec_args+=("$@"); }
      When call _orb_parse_declared_arg_options 1
      The variable "spec_args[@]" should equal "1 1 1"
    End
  End
End


Describe '_orb_get_declared_arg_options_start_indexes'
  _orb_raise_invalid_declaration() { echo "$@"; exit 1; }

  It 'calls _orb_is_declared_arg_options_start_index with arg and option_i'
    arg_options_declaration=(
      Default: value 
      Required: true
    )
    _orb_is_declared_arg_options_start_index() { spec_args+=("$@,");}
    When call _orb_get_declared_arg_options_start_indexes 1
    The variable "spec_args[@]" should equal "1 0, 1 1, 1 2, 1 3,"
  End

  It 'add option indexes to declared_arg_options_start_indexes'
    arg_options_declaration=(
      Default: value 
      Required: true
    )
    _orb_declared_args=(-f)

    When call _orb_get_declared_arg_options_start_indexes 1
    The variable "declared_arg_options_start_indexes[@]" should equal "0 2"
  End
  
  It 'handles flagged args'
    arg_options_declaration=(
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
    arg_options_declaration=(
      Default: spec multi line arr 
      Required: true
    )
    _orb_declared_args=(...)

    When call _orb_get_declared_arg_options_start_indexes 1
    The variable "declared_arg_options_start_indexes[@]" should equal "0 5"
  End
  
  It 'raises if option at end of declaration'
    arg_options_declaration=(
      Required: 
    )
    _orb_declared_args=(1)
    When run _orb_get_declared_arg_options_start_indexes 1
    The status should be failure
    The output should equal "Required: missing value"
  End

  It 'raises if non_catch_all option before another option'
    arg_options_declaration=(
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
  arg_options_declaration=(
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
  arg_options_declaration=(
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

# _orb_store_declared_arg_option_values
Describe '_orb_store_declared_arg_option_values'
  _orb_declared_args=(...)

  arg_options_declaration=(
    Default: some value
    In: value or other
    Required: true
    Catch: flag block
    Multiple: true
  )

  declared_arg_options_start_indexes=(0 3 7 9 12)
  declared_arg_options_lengths=(3 4 2 3 2)
  declared_arg_option_names=(Default: In: Required: Catch: Multiple:)

  It 'stores options to variables'
    When call _orb_store_declared_arg_option_values ...
    The variable "_orb_declared_option_values[@]" should eq "true some value value or other flag block true"
    The variable "_orb_declared_option_start_indexes[Required:]" should eq "0"
    The variable "_orb_declared_option_start_indexes[Default:]" should eq "1"
    The variable "_orb_declared_option_start_indexes[In:]" should eq "3"
    The variable "_orb_declared_option_start_indexes[Catch:]" should eq "6"
    The variable "_orb_declared_option_start_indexes[Multiple:]" should eq "8"
    The variable "_orb_declared_option_lengths[Required:]" should eq "1"
    The variable "_orb_declared_option_lengths[Default:]" should eq "2"
    The variable "_orb_declared_option_lengths[In:]" should eq "3"
    The variable "_orb_declared_option_lengths[Catch:]" should eq "2"
    The variable "_orb_declared_option_lengths[Multiple:]" should eq "1"
  End
End
