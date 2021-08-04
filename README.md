# orb-cli
`orb-cli` is a tool for building self-documenting command line utilities in bash. It removes the pain of parsing advanced command line options such as flags, blocks and wildcards. It also helps with argument validation and code organization through namespaces. 

---

## How it works

1. Create an orb extension folder with a namespace file inside
```BASH
mkdir -p ~/.orb-cli/namespaces
touch ~/.orb-cli/namespaces/my_namespace.sh
chmod +x ~/.orb-cli/namespaces/my_namespace.sh
```

2. Declare your function and arguments

```BASH
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
  echo "$1"
  echo "$2"
  echo "${_args['-b']}"
  echo "${_args['-f arg']}"

  # Blocks and wildcards only state true/false if received or not
  "${_args['*']}" && echo "got wildcard"

  # Their actual values are stored in separate variables 
  # (Bash does not support nested arrays)
  echo "${_args_block_b[@]}" # ['-b-']
  echo "${_args_wildcard[@]}" # ['*']
  echo "${_args_dash_wildcard[@]}" # ['-- *']

  
  # _print_args is a core function that helps you print recieved args for debugging
  # see orb core --help for more
}
```

3. Call your function
```
$ orb my_namespace my_function arg_1 arg_2 -bf arg_f -b- my block args -b- first wildcard -- dash wildcard

arg_1
arg_2
true
arg_f
got wildcard
my block args
first wildcard
dash wildcard
```
---
## Print help
```
$ orb my_namespace --help

-----------------     /home/user/.orb-cli
MY_NAMESPACE.SH
  my_function         This is my function comment
```

```
orb my_namespace my_function --help

my_function - This is my function comment

  ARG     DESCRIPTION                       DEFAULT  IN  REQUIRED  OTHER
  1       first inline argument             -        -   true      -
  2       second inline argument            -        -   true      -
  -b      boolean flag                      -        -   -         -
  -b-     matches block between -b- * -b-   -        -   -         -
  -f arg  flagged argument                  -        -   -         -
  -- *    rest of arguments                 -        -   true      -
  *       rest of arguments unless find --  -        -   true      -

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

## Orb extension folders

From now on i refer to them as `orb_ext_dir`:
  - `~/.orb-cli` - is user global orb extension folder. Which can be extended by any number of the following two folders found above you in the file system. This makes it easy to add project specific functionality.
  - `.orb-extension`
  - `_orb_extension`

## Namespaces
Your namespaces are defined by either a file or a folder with multiple files
  - `orb_ext_dir/namespaces/my_namespace.sh`
  - `orb_ext_dir/namespaces/my_namespace/file.sh`

### Core namespace
- `orb core --help` lists all core functions.
- All core functions can be called directly from within your own orb functions without orb prefix.

Some useful functions
- `_print_args` - prints received args after parsing
- `_args_to` - pass recevied args to array if received. Useful for creating command interfaces.
- `_raise_error` - raises formatted error and kills script


  

### Presource
If using a dedicated namespace folder you can also add
  - `orb_ext_dir/namespaces/my_namespace/_presource.sh` - will be sourced before functions in your namespace are called
- `orb_ext_dir/.env` - will be parsed into your scripts as exported variables.
- Core uses following `.env` vars
  - `ORB_DEFAULT_NAMESPACE` - if set to `my_namespace`, you can call `orb my_function` directly.


## Functions

Functions callable through orb and listed in help - aka. "`public functions`" - have to be declared inside your namespace files with `function` prefix and `()` suffix. If not it will be considered a "`private function`" that is used internally in the file.

---




## Advanced arguments 
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
```
 Note the available argument properties
 - Numbered args are required unless prop `OPTIONAL` or supplied `DEFAULT`
 - Flag and block args are optional unless prop `REQUIRED`
 - `IN` lists multiple accepted values with `|`
 - `DEFAULT` can eval variables and falls back through `|` chain when undef.
 - Numbered args and wildcards with `CATCH_ANY` allows dash to be first character in assignment. Otherwise the argument would be interpreted as an invalid flag.

Note:
 - If flags are single char you can pass multiple flag statements such as `-ri`.
 - Calling `orb my_function +r` sets `[-r]=false`. This is useful if `[-r]=DEFAULT: true` - Inspired by bash options https://tldp.org/LDP/abs/html/options.html
- Numbered args and wildcard args also passed as inline args to function call.
 This allows expected for bash positional arguments eg: `$1`, `$2`, `$@/$*` etc
