# This script is bash >= 4.3 only
#
# Because use eg:
# - arrays. Not supported in sh and in zsh indexes start at 1 instead of 0.
# - local function variables. Not supported in classic sh shells.
# - FUNCNAME and BASH_SOURCE lookup. Would have to be adapted for each shell if supported at all.
# - double bracket regex conditions.
# - associative arrays. requires bash_version >= 4
# - declare and namerefs. requires bash_version >= 4.3, released 2014
#   https://wiki.bash-hackers.org/commands/builtin/declare#nameref
#

if [ -z "$BASH" ]; then
  echo "Please use orb with bash" && return 1
elif ! (( ${BASH_VERSINFO[0]}${BASH_VERSINFO[1]} >= 43 )); then
  echo "Please use orb with bash version >= 4.3" && return 1
fi
