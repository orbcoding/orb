# orb-cli (in beta)
`orb` is a bash cli companion for developers. It functions as a wrapper for your bash commands and provides a simple interface for collecting more advanced arguments such as flags and wildcards. It also helps with setting default values, different types of validations, and auto generation of help docs.

---

## How it works

All you have to do is put your functions inside an orb extension namespace folder and define your arguments. Then you can call your cmd with `orb my_namespace my_cmd`


```BASH
touch ~/.orb-cli/namespaces/my_namespace.sh
chmod +x ~/.orb-cli/namespaces/my_namespace.sh

# OR if you want multiple files in your namespace
# touch ~/.orb-cli/namespaces/my_namespace/a_namespace_file.sh
# chmod +x ~/.orb-cli/namespaces/my_namespace/a_namespace_file.sh


# ~/.orb-cli/namespaces/my_namespace.sh

# my_function
declare -A my_function_args=(
  ['1']='first inline argument'
  ['2']='second inline argument'
  ['-b']='boolean flag'
  ['-f arg']='flagged argument'
  ['-b-']='matches block between -b- * -b-'
  ['*']='rest of arguments unless find --'
  ['-- *']='rest of arguments'
); function my_function() { # This is my function comment
  _print_args # prints your args for debugging

  echo
  echo "${_args[@]}"
	# easily check if arg recieved eg:
	"${_args['*']}" && echo "got wildcard"
  echo "${_args_wildcard[@]}"
  echo "${_args_block_b[@]}"
  echo "${_args_dash_wildcard[@]}"
}


# Then call your function
$ orb docker my_function -bf arg_f arg_1 arg_2 -b- my block args -b- first wildcard -- dash wildcard

# =>
# ([-b-]="true" [2]="arg_2" [1]="arg_1" ["*"]="true" ["-f arg"]="arg_f" [-b]="true" ["-- *"]="true" )
# [-b-]=my block args
# [*]=first wildcard
# [-- *]=dash wildcard

# -b- 2 1 * -f arg -b -- *
# true arg_2 arg_1 true arg_f true true
# got wildcard

# first wildcard
# my block args
# dash wildcard

$ orb my_namespace --help
# =>
# -----------------     /home/user/.orb-cli
# MY_NAMESPACE.SH
#   my_function         This is my function comment


$ orb my_namespace my_function --help
# =>
# my_function - This is my function comment
#
#   ARG     DESCRIPTION                       DEFAULT  IN  REQUIRED  OTHER
#   1       first inline argument             -        -   true      -
#   2       second inline argument            -        -   true      -
#   -b      boolean flag                      -        -   -         -
#   -b-     matches block between -b- * -b-   -        -   -         -
#   -f arg  flagged argument                  -        -   -         -
#   -- *    rest of arguments                 -        -   true      -
#   *       rest of arguments unless find --  -        -   true      -
```

---

## Installation
```BASH
  mkdir ~/.orb-cli && cd ~/.orb-cli
  git clone https://github.com/sharetransition/orb-cli.git
  # Extend path in ~/.bashrc or ~/.zshrc and resource/restart shell
  PATH=$PATH:~/.orb-cli/orb-cli

  # Now you can use the orb command
  orb --help
```
---

## orb extension folders

- From now on i refer to them as `orb_ext_dir`:
  - `~/.orb-cli` - is user global orb extension folder. Which can be extended by any number of the following two folders found above you in the file system. This makes it easy to add project specific functionality.
  - `.orb-extension`
  - `_orb_extension`
- Your functions are then placed in either of
  - `orb_ext_dir/namespaces/my_namespace.sh`
  - `orb_ext_dir/namespaces/my_namespace/file.sh` (supports multiple files)
- If using a dedicated folder you can also add
  - `orb_ext_dir/namespaces/my_namespace/_presource.sh` - that will be sourced before you functions are called
- You can also add `.env` files which will be parsed into your scripts as exported variables.
  - `orb_ext_dir/.env`
- Core uses following `.env` vars
  - `ORB_DEFAULT_NAMESPACE` - if set to `my_namespace`, you can call `orb my_function` directly.

---

## Arguments and functions

Functions callable through orb and listed in help - aka. "`public functions`" - have to be declared with `function` prefix and `()`. If not it will be considered a "`private function`" that is used internally in the file.

Here is a more advanced argument declaration

```BASH
 declare -A my_function_args=(
  ['1']='short description of first arg; IN: value1|value2|value3; DEFAULT: $checkedvar1|$checkedvar2|value3'
  ['2']='second arg; OPTIONAL'
  ['-r']='r flag description; DEFAULT: true'
  ['--verbose-flag']='if desired'
  ['-e arg']='flagged arg; REQUIRED'
  ['*']='matches rest of args when args not declared or invalid; CATCH_ANY'
 ); function my_function() { ... }

 If flags are single char you can pass multiple flag statements such as -ri

 calling `orb my_function +r` sets [-r]=false. Useful if [-r]=DEFAULT: true - Inspired by bash options https://tldp.org/LDP/abs/html/options.html

 Note the available argument properties
 - Numbered args are required unless prop OPTIONAL or supplied DEFAULT
 - Flag and block args are optional unless prop REQUIRED
 - IN lists multiple accepted values with |
 - DEFAULT can eval variables and falls back through | chain when undef.
 - inline args with CATCH_ANY allows unrecognized flag or block to start assignment. Otherwise invalid argument error is raised.


 Values are then stored in $_args associative array
 and can be retrieved by eg:

 ${_args["-e arg"]} => arg_value if flagged_arg received
 ${_args[-e]} => true if flag received, otherwise false
 ${_args[-b-]} => true if block received, otherwise false
 ${_args['*']} => true if wildcard arguments received, otherwise false
 ${_args['-- *']} => true if dash wildcard arguments received, otherwise false
 # Using separate variables for array inputs as bash does not support nested arrays
 ${_args_block_b[@]} holds block args 
 ${_args_wildcard[@]} holds wildcard args 
 ${_args_dash_wildcard[@]} holds dash wildcard args 

 Numbered args and wildcard args also passed as inline args to function call.
 This allows expected access through: $1, $2, $@/$* etc


 If the first argument of any function is --help
 An argument help output will be printed
```

---
## Core namespace
- `orb core --help` lists all core functions.
- All core functions can be called directly from within your own orb functions without orb prefix.

Some useful functions
- `_print_args` - prints received args after parsing
- `_args_to` - pass recevied args to array if received. Useful for creating command interfaces.
- `_raise_error` - raises formatted error and kills script
