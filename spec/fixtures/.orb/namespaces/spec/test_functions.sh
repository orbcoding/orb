declare -A test_orb_print_args_args=(
  flag = -f
  flagged_arg = -a 1
  verbose_flag = --verbose-flag 
  verbose_flagged_arg = --verbose-flagged 1 
  block = -b-
  dash_args = --  
  rest = ... Optional
   
  # ['-f']='flag'
  # ['-a arg']='flagged arg'
  # ['--verbose-flag']='arg'
  # ['--verbose-flagged arg']='verbose flagged arg'
  # ['-b-']='block args'
  # ['*']='rest args'
  # ['-- *']='dash rest args; OPTIONAL'
); function test_orb_print_args() {
  source orb
  orb_print_args
}

test_orb_print_args_input_args=( 
  -f 
  -a "Flagged arg" 
  --verbose-flag
  --verbose-flagged-arg "Verbose flagged arg"
  -b- block args -b-
  rest args
  -- dash args
)

test_orb_print_args_output='([--verbose-flag]="true" [-b-]="true" ["-a arg"]="flag" ["*"]="true" [-f]="true" ["-- *"]="true" ["--verbose-flagged arg"]="flagged_arg" )
[-b-]=block args
[*]=rest args
[-- *]=dash rest args'

private_function() {
  :
}

function private_function2()
{
  :
}


 hej=function # another
dude=caspita # dude
