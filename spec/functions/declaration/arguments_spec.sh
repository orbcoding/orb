Include functions/utils/argument.sh
Include functions/declaration/arguments.sh
Include functions/declaration/checkers.sh
Include functions/declaration/validation.sh

_orb_function_declaration=(
  -f = flag
  -a 1 = flagged_arg
    Required: true
  --verbose-flag = verbose_flag 
  --verbose-flagged 1 = verbose_flagged_arg 
  -b- = block # i = 16-18
  -- = dash_args  
  ... = rest 
    Required: false
)



# _orb_parse_declared_args
Describe '_orb_parse_declared_args'
  It 'calls its functions'
    _orb_get_declarad_args_and_start_indexes() { spec_fns+=( $(echo_fn) ); }
    _orb_validate_declared_args() { spec_fns+=( $(echo_fn) ); }
    _orb_get_declared_args_lengths() { spec_fns+=( $(echo_fn) ); }
    _orb_parse_declared_args_options() { spec_fns+=( $(echo_fn) ); }
    When call _orb_parse_declared_args
    The status should be success
    The variable 'spec_fns[@]' should equal "_orb_get_declarad_args_and_start_indexes _orb_validate_declared_args _orb_get_declared_args_lengths _orb_parse_declared_args_options"
  End
End

# _orb_get_declarad_args_and_start_indexes
Describe '_orb_get_declarad_args_and_start_indexes'
  declare -A declared_args_start_indexes
  declare -a _orb_declared_args
  declare -A _orb_declared_vars
  declaration=("${_orb_function_declaration[@]}")

  It 'stores args, vars and start indexes'
    When call _orb_get_declarad_args_and_start_indexes
    The status should be success
    The variable "_orb_declared_args[@]" should equal "-f -a --verbose-flag --verbose-flagged -b- -- ..."

    vars_declaration="$(declare -p _orb_declared_vars)"
    The variable "vars_declaration[@]" should equal 'declare -A _orb_declared_vars=([...]="rest" [-b-]="block" [--]="dash_args" [-f]="flag" [-a]="flagged_arg" [--verbose-flag]="verbose_flag" [--verbose-flagged]="verbose_flagged_arg" )'
    
    start_index_declaration="$(declare -p declared_args_start_indexes)"
    The variable "start_index_declaration[@]" should equal 'declare -A declared_args_start_indexes=([...]="22" [-b-]="16" [--]="19" [-f]="0" [-a]="3" [--verbose-flag]="9" [--verbose-flagged]="12" )'
  End

  Context 'declared direct call'
    It 'stores var if valid var'
      _orb_declared_raw_args=true
      declaration=(
        -f = "flag"
      )
      When call _orb_get_declarad_args_and_start_indexes
      The variable "_orb_declared_vars[-f]" should equal "flag"
      The variable "_orb_declared_comments[-f]" should be undefined
    End

    It 'stores var to comment if invalid var'
      _orb_declared_raw_args=true
      declaration=(
        -f = "flag comment"
      )
      When call _orb_get_declarad_args_and_start_indexes
      The variable "_orb_declared_vars[-f]" should be undefined
      The variable "_orb_declared_comments[-f]" should equal "flag comment"
    End
  End
End

# _orb_get_declared_args_lengths
Describe '_orb_get_declared_args_lengths'
  declaration=("${_orb_function_declaration[@]}")
  declare -A declared_args_lengths
  declare -A declared_args_start_indexes=([...]="22" [-b-]="16" [--]="19" [-f]="0" [-a]="3" [--verbose-flag]="9" [--verbose-flagged]="12" )
  declare -a _orb_declared_args=( -f -a --verbose-flag --verbose-flagged -b- -- ... )

  It 'stores length in declared_args_lengths array'
    When call _orb_get_declared_args_lengths
    The status should be success
    length_declaration=$(declare -p declared_args_lengths)
    The variable "length_declaration" should equal 'declare -A declared_args_lengths=([...]="5" [-b-]="3" [--]="3" [-f]="3" [-a]="6" [--verbose-flag]="3" [--verbose-flagged]="4" )'
  End
End


