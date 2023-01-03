# Code guidelines

`Bash` lessons learned and `orb` specifics, for advanced users and developers. 

When orb calls a function, it does not create an isolated subshell. This enables us to set and modify variables in the scope of the calling function and beyond. For example:

```BASH
# namespace = arr
function create() {
  arr=(1 2)
  local appended

  orb arr append

  echo "appended=$appended"
}

function append() {
  appended=true
  arr+=(3 4)  
}

orb arr create
# appended=true

echo "${arr[@]}"
# 1 2 3 4

echo $appended # undefined in global scope
# 
```

This freedom demands attention to naming and scoping to prevent pollution and collision between user defined variables and functions and those belonging to the orb core.

## Scoping
- Bash supports the `local` keyword for variables defined inside functions.
  
- When defining variables with `declare`, they are local by default if declared in the scope of a function - otherwise they fall back to being global. This enables us to occasionally source a script with local variables outside of functions, without bash throwing an error as it would have done with the `local` keyword. This proved useful for testing.

- Functions are always global in bash. 
  
  When orb sources the files necessary to call the specified function, any functions or variables inside those files will also be declared. `orb` provides the `--restore-functions` option to ensure that no functions in the calling scope are overwritten.


### Global variables

- All global variables as well as function names should be prefixed with `_orb_`. The only exception being specific shared core functions that are instead prefixed with `orb_`. For example `orb_pass`.
  
- Most "global" variables in the `orb` core are not really global, but rather `local` variables in the `orb` function scope. This is the scope directly above the called function. With exceptions such as `initialize` and `history` variables. Each time orb calls a function it redeclares the same `call` variables before calling the specified function. This prevents pollution between calls, while maintaining function call data in the local scope.

### Local variables 
- Variables inside functions should be declared `local`. 

  As they won't pollute the environment they can be named freely - **EXCEPT** Inside functions where we have to assign values to user defined variable names. This is particularily true in argument `collection` and `assignment` functions where we need to be able to assign argument values to the variable names specified in the user argument declaration. In these cases all variables have to be `_orb_` prefixed.
  
  Consider the example below. If we would have created a local variable named `first` anywhere in the chain of functions leading to the assignment `first=value` - This would have prevented the users variable from receiving its value. 

  **OBS:** Note that `orb` does declare the variable `first` as a local variable in the scope of the orb function directly above the called function. This prevents any subsequent orb calls to functions with the same argument assignment variable names to overwrite the parent variable values.


```BASH
# namespace = ns
fn_orb=(
  1 = first
)
function fn() {
  echo $first
  orb ns fn2 value2 # does not overwrite local "first" variable
  echo $first
}

fn2_orb=(
  1 = first
)
function fn2() {
  echo $first
  first=value3 # cannot modify "first" variable in fn as "first" in fn2 is local 
}

orb ns fn value
# value
# value2
# value
```

## Namerefs
When using `declare -n`. Make sure to avoid this circular reference pitfall, always prefix variable with `_orb_` if the provided variable name is uncertain:

```BASH
function nameref_pitfall() {
  declare -n arr=$1
  arr+=(3 4)
}

arr=(1 2)
nameref_pitfall arr
# declare: warning: arr: circular name reference
```

