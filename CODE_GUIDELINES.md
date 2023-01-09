# Code guide

`Bash` lessons learned and `orb` specifics, for advanced users and developers. 

As orb functions can interact with eachother freedom demands attention to naming and scoping to prevent pollution and collision between user defined variables and functions and those belonging to the orb core.

- Bash supports the `local` keyword for variables defined inside functions.
  
- When defining variables with `declare`, they are local by default if declared in the scope of a function - otherwise they fall back to being global. This enables us to occasionally source a script with local variables outside of functions, without bash throwing an error as it would have done with the `local` keyword. This proved useful for testing.

- Functions are always global in bash. 
  
  When orb sources the files necessary to call the specified function, any functions or variables inside those files will also be declared. `orb` provides the `--restore-functions` option to ensure that no functions in the calling scope are overwritten.


## Global variables

- All global variables as well as function names should be prefixed with `_orb_`. The only exception being specific shared core functions that are instead prefixed with `orb_`. For example `orb_pass`.
  
- Most "global" variables in the `orb` core are not really global, but rather `local` variables in the `orb` function scope. This is the scope directly above the called function. With exceptions being mainly `initialize` variables. Each time orb calls a function it redeclares the same `call` variables before calling the specified function. This prevents pollution between calls, while maintaining function call data in the local scope.

## Local variables 
- Variables inside functions should be declared `local`. 

- As they won't pollute the environment they can be named freely - **EXCEPT** when there is risk of variable shadowing.

## Variable shadowing and indirection

  Variable shadowing can occur in functions that assign values to variables in an outer scope. If a local function variable is declared with the same name as the outer variable, it will shadow, or prevent assignment to the outer scope.
   
  In practise unintended shadowing happens mostly in the context *indirection* - When the name of the outer variable is defined by a user and received as an input argument. In such cases assignment is done with the help of *namerefs*, `declare -n`, or possibly with `eval`. In these types of functions all local variables, including *namerefs*, should be `_orb_` prefixed. Consider the example below:

```BASH
function nameref_pitfalls() {
  declare -n arr=$1
  local append=(3 4)
  arr+=(${append[@]})
  echo "${arr[@]}"
}

# Intended output
array=(1 2)
nameref_pitfalls array
# 1 2 3 4

arr=(1 2)
nameref_pitfalls arr
# declare: warning: arr: circular name reference
# ...

append=(1 2)
nameref_pitfalls append
# 3 4 3 4
```
  
  Shadowing also occurs intentionally to prevent unintended assignment. For example the orb function parameters are declared `local` to each function call - in the `orb` function scoped directly above the called function. 
  
  Consider the example below. By declaring the parameter `word` as a local variable we prevent any subsequent orb calls to functions with the same parameter names to modify the parent function parameters.


```BASH
# namespace = arguments
print_orb=(
  1 = word
)
function print() {
  echo $word
  orb arguments print_nested hello_nested
  echo $word
}

print_nested_orb=(
  1 = word
)
function print_nested() {
  echo $word
  word=hello_nested_updated # word in print_nested is local, so will not update word in print
  echo $word
}

orb arguments print hello
# hello
# hello_nested
# hello_nested_updated
# hello
```

## Parameters and arguments
    A parameter is a variable in a method definition. When a method is called, the arguments are the data you pass into the method's parameters.

    You define parameters, and you make arguments.

Hence, `orb` collects the arguments and assigns them to the parameters declared in the function's orb declaration. 


