declare -A test_orb_fn_args=(
  ['-f']='flag'
  ['-a arg']='flagged arg'
  ['--verbose-flag']='arg'
  ['--verbose-flagged arg']='verbose flagged arg'
  ['-b-']='block args'
  ['*']='wildcard args'
  ['-- *']='dash wildcard args; OPTIONAL'
); function test_orb_fn() {
  source orb
  _print_args
}

test_orb_fn_input_args=( 
  -f 
  -a flag 
  --verbose-flag
  --verbose-flagged flagged_arg
  -b- block args -b-
  wildcard args
  -- dash wildcard args
)

test_orb_fn_print_args='([--verbose-flag]="true" [-b-]="true" ["-a arg"]="flag" ["*"]="true" [-f]="true" ["-- *"]="true" ["--verbose-flagged arg"]="flagged_arg" )
[-b-]=block args
[*]=wildcard args
[-- *]=dash wildcard args'

private_function() {
  :
}

function private_function2()
{
  :
}
