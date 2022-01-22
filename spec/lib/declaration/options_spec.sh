Include lib/utils/argument.sh
# Include lib/utils/utils.sh
Include lib/declaration/argument_options.sh
Include lib/helpers/declaration/general.sh
Include lib/helpers/declaration/argument_options.sh

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
    Optional: true
)

# _orb_parse_args_options_declaration
Describe '_orb_parse_args_options_declaration'
  It 'calls _orb_set_declared_arg_options_defaults and _orb_parse_arg_options_declaration with i'
    _orb_declared_args=(spec args)
    _orb_set_declared_arg_options_defaults() { spec_args+=("$@"); }
    _orb_get_arg_options_declaration() { spec_args2+=("$@"); }
    _orb_prevalidate_arg_options_declaration() { spec_args3+=("$@");}
    _orb_parse_arg_options_declaration() { spec_args4+=("$@"); }
    _orb_postvalidate_declared_args_options() { echo_me; }
    When call _orb_parse_args_options_declaration
    The variable "spec_args[@]" should equal "0 1"
    The variable "spec_args2[@]" should equal "0 1"
    The variable "spec_args3[@]" should equal "0 1"
    The variable "spec_args4[@]" should equal "0 1"
    The output should include "_orb_postvalidate_declared_args_options"
  End

  Context 'holistic testing'
    _orb_declared_args=(1 -a)
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

    arg_declaration_indexes=( 0 14 )
    arg_declaration_lengths=( 14 15 )
    
    It 'stores options to variables'
      When call _orb_parse_args_options_declaration
      The variable "_orb_declared_arg_requireds[@]" should equal "false true"
      The variable "_orb_declared_arg_comments[@]" should equal "This is first comment This is flagged comment"
      The variable "_orb_declared_arg_defaults[@]" should equal "value value"
      The variable "_orb_declared_arg_defaults_indexes[@]" should equal "0 1"
      The variable "_orb_declared_arg_defaults_lengths[@]" should equal "1 1"
      The variable "_orb_declared_arg_ins[@]" should equal "first value or other second value or other"
      The variable "_orb_declared_arg_ins_indexes[@]" should equal "0 4"
      The variable "_orb_declared_arg_ins_lengths[@]" should equal "4 4"
    End
  End
End

# _orb_set_declared_arg_options_defaults
Describe '_orb_set_declared_arg_options_defaults'
  _orb_declared_args=(-f 1 --verbose-flag)

  It 'sets empty suffixes'
    When call _orb_set_declared_arg_options_defaults 0
    The variable "_orb_declared_arg_suffixes[0]" should equal ""
  End

  It 'sets required = false for flags'
    When call _orb_set_declared_arg_options_defaults 0
    The variable "_orb_declared_arg_requireds[0]" should equal false
  End

  It 'sets required = true for other'
    When call _orb_set_declared_arg_options_defaults 1
    The variable "_orb_declared_arg_requireds[0]" should equal true
  End

  It 'sets empty default_indexes'
    When call _orb_set_declared_arg_options_defaults 0
    The variable "_orb_declared_arg_defaults_indexes[0]" should equal ""
    The variable "_orb_declared_arg_defaults_lengths[0]" should equal ""
  End
End

# _orb_get_arg_options_declaration
Describe '_orb_get_arg_options_declaration'
  _orb_declared_args=(1 -a)
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
  arg_options_declaration=()
	arg_declaration_indexes=(0 14)
	arg_declaration_lengths=(14 15)


  It 'gets options declaration'
    When call _orb_get_arg_options_declaration 0
    The variable "arg_options_declaration[@]" should equal "Required: false Comment: This is first comment Default: value In: first value or other"
  End

  It 'gets options declaration without suffix'
    When call _orb_get_arg_options_declaration 1
    The variable "arg_options_declaration[@]" should equal "Required: true Comment: This is flagged comment Default: value In: second value or other"
  End

  It 'calls _orb_parse_arg_options_declaration_arg_suffix with args_i start_i+3'
    _orb_parse_arg_options_declaration_arg_suffix() { echo "$@"; }
    When call _orb_get_arg_options_declaration 1
    The output should equal "1 17"
  End
End


# _orb_parse_arg_options_declaration
Describe '_orb_parse_arg_options_declaration'
  Context 'testing internal calls'
    _orb_get_arg_option_declaration_indexes() { :; }
    _orb_get_arg_option_declaration_lengths() { :; }
    _orb_store_declared_arg_options() { :; }


    It 'calls correct functions with args_i'
      _orb_get_arg_option_declaration_indexes() { spec_args+=("$@"); }
      _orb_get_arg_option_declaration_lengths() { spec_args+=("$@"); }
      When call _orb_parse_arg_options_declaration 1
      The variable "spec_args[@]" should equal "1 1"
    End

    It 'calls rest of functions without parameters'
      _orb_store_declared_arg_options() { spec_fns+=( $(echo_me) ); }

      When call _orb_parse_arg_options_declaration 1
      The variable "spec_fns[@]" should equal "_orb_store_declared_arg_options" 
    End
  End
End


# _orb_parse_arg_options_declaration_arg_suffix
Describe '_orb_parse_arg_options_declaration_arg_suffix'
  _orb_declared_arg_suffixes=()
  _orb_declared_args=(-f -a) # ... start of declaration args

  It 'succeeds and stores suffix if arg is any flag and suffix is nr'
    When call _orb_parse_arg_options_declaration_arg_suffix 1 6
    The status should be success
    The variable "_orb_declared_arg_suffixes[1]" should equal "1"
  End

  It 'otherwise returns failure'
    When call _orb_parse_arg_options_declaration_arg_suffix 1 7
    The status should be failure
  End
End


Describe '_orb_prevalidate_arg_options_declaration'
  _orb_raise_invalid_declaration() { echo "$@"; return 1; }

  It 'should raise invalid declaration if first option str is not valid option'
    arg_options_declaration=(invalid option)
    _orb_declared_args=(-f)

    When call _orb_prevalidate_arg_options_declaration 0
    The status should be failure
    The output should equal "Options must start with valid option"
  End

  It 'should not raise anything if first is valid option'
    arg_options_declaration=(Required: true)
    _orb_declared_args=(-f)

    When call _orb_prevalidate_arg_options_declaration 0
    The status should be success
  End
End

Describe '_orb_get_arg_option_declaration_indexes'
  _orb_raise_invalid_declaration() { echo "$@"; exit 1; }

  It 'calls _orb_is_arg_option_declaration_index with arg_i and option_i'
    arg_options_declaration=(
      Default: value 
      Required: true
    )
    _orb_is_arg_option_declaration_index() { spec_args+=("$@,");}
    When call _orb_get_arg_option_declaration_indexes 0
    The variable "spec_args[@]" should equal "0 0, 0 1, 0 2, 0 3,"
  End

  It 'add option indexes to arg_option_declaration_indexes'
    arg_options_declaration=(
      Default: value 
      Required: true
    )
    _orb_declared_args=(-f)

    When call _orb_get_arg_option_declaration_indexes 0
    The variable "arg_option_declaration_indexes[@]" should equal "0 2"
  End
  
  It 'handles flagged args'
    arg_options_declaration=(
      Default: spec 
      Required: true
      In: spec
    )
    _orb_declared_args=(-f)
    _orb_declared_arg_suffixes=(1)

    When call _orb_get_arg_option_declaration_indexes 0
    The variable "arg_option_declaration_indexes[@]" should equal "0 2 4"
  End

  It 'handles array input'
    arg_options_declaration=(
      Default: spec multi line arr 
      Required: true
    )
    _orb_declared_args=(...)

    When call _orb_get_arg_option_declaration_indexes 0
    The variable "arg_option_declaration_indexes[@]" should equal "0 5"
  End
  
  It 'raises if option at end of declaration'
    arg_options_declaration=(
      Required: 
    )
    _orb_declared_args=(1)
    When run _orb_get_arg_option_declaration_indexes 0
    The status should be failure
    The output should equal "Required: missing value"
  End

  It 'raises if non_catch_all option before another option'
    arg_options_declaration=(
      Required: Default: 
    )
    _orb_declared_args=(1)
    When run _orb_get_arg_option_declaration_indexes 0
    The status should be failure
    The output should equal "Required: invalid value: Default:"
  End

  It 'allows option as first value for Default:'
    arg_options_declaration=(
      Default: Required:
      Required: true
    )
    _orb_declared_args=(-f)
    When call _orb_get_arg_option_declaration_indexes 0
    The variable "arg_option_declaration_indexes[@]" should equal "0 2"
  End

  It 'allows option as first value for In:'
    arg_options_declaration=(
      In: Default: 
      Required: true
    )
    _orb_declared_args=(1)
    When call _orb_get_arg_option_declaration_indexes 0
    The variable "arg_option_declaration_indexes[@]" should equal "0 2"
  End
End


# _orb_is_arg_option_declaration_index
Describe '_orb_is_arg_option_declaration_index'
  # Mostly holistically tested by _orb_get_arg_option_declaration_indexes
  It 'succeeds for valid option indexes'
    arg_options_declaration=(
      In: value
      Required: true
    )
    _orb_declared_args=(1)
    When call _orb_is_arg_option_declaration_index 0 0
    The status should be success
  End

  It 'fails on non option indexes'
    arg_options_declaration=(
      In: value 
      Required: true
    )
    _orb_declared_args=(1)
    When call _orb_is_arg_option_declaration_index 0 1
    The status should be failure
  End
End


# _orb_get_arg_option_declaration_lengths
Describe '_orb_get_arg_option_declaration_lengths'
  arg_options_declaration=(
    Default: Default values
    Comment: "Value"
    Required: true
  )
  arg_option_declaration_indexes=(0 3 5)
  arg_option_declaration_lengths=()

  It 'stores length of options in arg_option_declaration_lengths array'
    When call _orb_get_arg_option_declaration_lengths
    The variable "arg_option_declaration_lengths[@]" should equal "3 2 2"
  End
End




# _orb_is_valid_arg_option
Describe '_orb_is_valid_arg_option'
  _orb_raise_invalid_declaration() { echo "$@"; return 1; }

  _orb_declared_args=(-f 1 ...)
  _orb_declared_arg_suffixes=("" "" "")
  arg_options_declaration=(
    Default: value
    In: value
    Required: true 
  )

  It 'suceeds for Default:'
    When call _orb_is_valid_arg_option 0 0
    The status should be success
  End

  It 'fails for boolean with invalid boolean option'
    When call _orb_is_valid_arg_option 0 2
    The status should be failure
    The output should equal "-f, In: not valid option for boolean flags"
  End

  It 'succeeds for nr with invalid boolean option'
    When call _orb_is_valid_arg_option 1 2
    The status should be success
  End

  It 'fails for ... with invalid array option'
    When call _orb_is_valid_arg_option 2 2
    The status should be failure
    The output should equal "..., In: not valid option for array arguments"
  End
End


# _orb_store_declared_arg_options
Describe '_orb_store_declared_arg_options'
  _orb_declared_args=(...)

  arg_options_declaration=(
    Default: some value
    In: value or other
    Required: true
    Comment: "This is my comment"
  )

  arg_option_declaration_indexes=(0 3 7 9)
  arg_option_declaration_lengths=(3 4 2 2)
  _orb_set_declared_arg_options_defaults 0

  It 'stores options to variables'
    When call _orb_store_declared_arg_options 
    The variable "_orb_declared_arg_requireds[@]" should equal true
    The variable "_orb_declared_arg_comments[@]" should equal "This is my comment"
    The variable "_orb_declared_arg_defaults[@]" should equal "some value"
    The variable "_orb_declared_arg_defaults_indexes[@]" should equal "0"
    The variable "_orb_declared_arg_defaults_lengths[@]" should equal "2"
    The variable "_orb_declared_arg_ins[@]" should equal "value or other"
    The variable "_orb_declared_arg_ins_indexes[@]" should equal "0"
    The variable "_orb_declared_arg_ins_lengths[@]" should equal "3"
  End
End


# _orb_postvalidate_declared_args_options
Describe '_orb_postvalidate_declared_args_options'
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

  _orb_declared_args=(1 -a)
  _orb_declared_arg_suffixes=("" 1)
  _orb_declared_arg_defaults=(value value)
  _orb_declared_arg_requireds=(false true)
  _orb_declared_comments=("This is first comment" "This is flagged comment")
  # ...

  It 'succeeds on valid args'
    When call _orb_postvalidate_declared_args_options
    The status should be success
  End

  # It 'fails on invalid...'
  # End
End
