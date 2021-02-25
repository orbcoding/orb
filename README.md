# orb-cli (in beta)
`orb` is a bash cli companion for developers. It functions as a wrapper for your bash commands and provides a simple interface for collecting more advanced arguments such as flags and wildcards. It also helps with setting default values, different types of validations, and the auto generation of help docs.

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
  ['-f arg']='flag followed by argument'
  ['*']='rest of arguments'
); function my_function() { # This is my function comment
  echo "$1 $2"
  ${_args[-b]} && echo "got -b"
  echo "got -f arg: ${_args[-f arg]}"
  echo "rest of args: ${_args_wildcard[@]}"
}


# Then call your function
$ orb my_namespace my_function -bf arg_f arg_1 arg_2 some more args
# =>
#  arg_1 arg_2
#  got -b
#  got -f arg: arg_f
#  rest of args: some more args

$ orb my_namespace --help
# =>
# -----------------     /home/user/.orb-cli
# MY_NAMESPACE.SH
#   my_function         This is my function comment


$ orb my_namespace my_function --help
# =>
#  my_function - This is my function comment
#
#    ARG     DESCRIPTION                DEFAULT  IN  REQUIRED  OTHER
#    1       first inline argument      -        -   true      -
#    2       second inline argument     -        -   true      -
#    -b      boolean flag               -        -   -         -
#    -f arg  flag followed by argument  -        -   -         -
#    *       rest of arguments          -        -   true      -
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
  - `orb_ext_dir/namespaces/my_namespace/_presource.sh` - that will be sourced before you function is called
- You can also add `.env` files which will be parsed into your scripts as exported variables.
  - `orb_ext_dir/.env`
- Core uses following `.env` vars
  - `ORB_DEFAULT_NAMESPACE` - if set to `my_namespace`, you can call `orb my_function` directly.

---

## Arguments and functions

Functions callable through orb and listed in help - aka. "`public functions`" - have to be declared with `function` prefix and `()`. If not it will be considered a "`private function`" that is used internally in the file. See `orb core _has_public_function` for internal logic.

Here is a more advanced argument declaration

```BASH
 declare -A my_function_args=(
  ['1']='short description of first arg; IN: value1|value2|value3; DEFAULT: $checkedvar1|$checkedvar2|value3'
  ['2']='second arg; OPTIONAL'
  ['-r']='r flag description; DEFAULT: true'
  ['-e arg']='-e flag followed by value arg; REQUIRED'
  ['*']='matches rest of args when args not declared or optional arguments fail IN-validation'
 ); function my_function() { ... }

 Boolean flags should be single char to allow multiple flag statements such as -ri

 calling `orb my_function +r` sets [-r]=false. Useful if [-r]=DEFAULT: true - Inspired by bash options https://tldp.org/LDP/abs/html/options.html

 Note the available argument properties
 - Numbered args are required unless prop OPTIONAL or supplied DEFAULT
 - Flag args are optional unless prop REQUIRED
 - IN lists multiple accepted values with |
 - DEFAULT can eval variables and falls back through | chain when undef.
 - ['*'] or ['1'] (any nr) with ACCEPTS_FLAGS allows unrecognized flag to start assignment. Otherwise invalid flag error is raised.


 Values are then stored in $_args associative array
 and can be retrieved by eg:

 ${_args["-e arg"]} => arg_value if applied
 ${_args[-e]} => true if applied, otherwise false
 ${_args['*']} => true if wildcard arguments assigned, otherwise false
 ${_args_wildcard[@]} holds wildcard args (separate variable as bash does not support nested arrays)

 Numbered args and wildcards also passed as inline args to function call.
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
