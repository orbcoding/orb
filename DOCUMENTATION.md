## Scope and environment access

When you call `orb` in a terminal or script, by default, the orb script will be executed in a `bash` subshell. This standard behavior makes it possible to call bash scripts in other shells such as `zsh`. It also means your orb functions cannot modify the environment in the calling scope. 

However, if you are already in a compatible `bash` environment, the orb script can instead be sourced for initialization within the current environment.

Once the orb script has been initialized, a function named `orb` is declared to replace the orb script. Any `orb` calls will then simply invoke this function without creating a new subshell.

For example:

```BASH
# ~/.orb/namespaces/arr.sh
function create() {
  arr=(1 2)
  # invoke the orb function in current shell
  orb arr append 
  echo ${arr[@]}
}

function append() {
  arr+=(3 4)  
}

# In any shell
$ orb arr create # invoke the orb script in a bash subshell
#> 1 2 3 4

$ echo "${arr[@]}" # undefined in outer scope
#> 

$ exec bash
$ source orb # initialize orb in current environment
$ orb arr create # invoke the orb function in current shell
#> 1 2 3 4

$ echo "${arr[@]}"
#> 1 2 3 4
```
