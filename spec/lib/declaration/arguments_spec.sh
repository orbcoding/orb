Include lib/utils/argument.sh
Include lib/declaration/arguments.sh
Include lib/helpers/declaration/general.sh

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

# _orb_parse_declaration
Describe '_orb_parse_declaration'
  Include lib/declaration/argument_options.sh
  Include lib/helpers/declaration/argument_options.sh

  It 'calls its nested functions'
    _orb_prevalidate_declaration() { spec_fns+=( $(echo_me) ); }
    _orb_parse_declared_args() { spec_fns+=( $(echo_me) ); }
    _orb_parse_declared_args_options() { spec_fns+=( $(echo_me) ); }
    When call _orb_parse_declaration
    The variable "spec_fns[@]" should equal "_orb_prevalidate_declaration _orb_parse_declared_args _orb_parse_declared_args_options"
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
    The variable "_orb_declared_defaults_start_indexes[@]" should equal "0 1"
    The variable "_orb_declared_defaults_lengths[@]" should equal "1 1"
    The variable "_orb_declared_ins[@]" should equal "first value or other second value or other"
    The variable "_orb_declared_ins_start_indexes[@]" should equal "0 4"
    The variable "_orb_declared_ins_lengths[@]" should equal "4 4"
  End
End

# _orb_parse_declared_args
Describe '_orb_parse_declared_args'
  It 'calls its functions'
    _orb_get_declarad_args_and_start_indexes() { spec_fns+=( $(echo_me) ); }
    _orb_get_declared_args_lengths() { spec_fns+=( $(echo_me) ); }
    When call _orb_parse_declared_args
    The status should be success
    The variable 'spec_fns[@]' should equal "_orb_get_declarad_args_and_start_indexes _orb_get_declared_args_lengths"
  End
End

# _orb_get_declarad_args_and_start_indexes
Describe '_orb_get_declarad_args_and_start_indexes'
  declare -A declared_args_start_indexes
  declare -a _orb_declared_args
  declare -A _orb_declared_vars
  declaration=("${_orb_declaration[@]}")

  It 'stores args, vars and start indexes'
    When call _orb_get_declarad_args_and_start_indexes
    The status should be success
    The variable "_orb_declared_args[@]" should equal "-f -a --verbose-flag --verbose-flagged -b- -- ..."

    vars_declaration="$(declare -A | grep _orb_declared_vars)"
    The variable "vars_declaration[@]" should equal 'declare -A _orb_declared_vars=([...]="rest" [-b-]="block" [--]="dash_args" [-f]="flag" [-a]="flagged_arg" [--verbose-flag]="verbose_flag" [--verbose-flagged]="verbose_flagged_arg" )'
    
    start_index_declaration="$(declare -A | grep declared_args_start_indexes)"
    The variable "start_index_declaration[@]" should equal 'declare -A declared_args_start_indexes=([...]="22" [-b-]="16" [--]="19" [-f]="0" [-a]="3" [--verbose-flag]="9" [--verbose-flagged]="12" )'
  End
End

# _orb_get_declared_args_lengths
Describe '_orb_get_declared_args_lengths'
  declaration=("${_orb_declaration[@]}")
  declare -A declared_args_lengths
  declare -A declared_args_start_indexes=([...]="22" [-b-]="16" [--]="19" [-f]="0" [-a]="3" [--verbose-flag]="9" [--verbose-flagged]="12" )
  declare -a _orb_declared_args=( -f -a --verbose-flag --verbose-flagged -b- -- ... )

  It 'stores length in declared_args_lengths array'
    When call _orb_get_declared_args_lengths
    The status should be success
    length_declaration=$(declare -A | grep declared_args_lengths)
    The variable "length_declaration" should equal 'declare -A declared_args_lengths=([...]="5" [-b-]="3" [--]="3" [-f]="3" [-a]="6" [--verbose-flag]="3" [--verbose-flagged]="4" )'
  End
End


