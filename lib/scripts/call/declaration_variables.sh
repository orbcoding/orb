declare -a _orb_declared_args # ordered
# Argument as key: eg: -f
# TODO might verbose _orb_declared_arg_vars etc
declare -A _orb_declared_arg_suffixes
declare -A _orb_declared_vars
declare -A _orb_declared_requireds
declare -A _orb_declared_comments

# Separate normal array stores to maintain word separation
# Tracked by index and length
declare -a _orb_declared_defaults
declare -A _orb_declared_defaults_start_indexes
declare -A _orb_declared_defaults_lengths

declare -a _orb_declared_ins
declare -A _orb_declared_ins_start_indexes
declare -A _orb_declared_ins_lengths

declare -a _orb_declared_catchs
declare -A _orb_declared_catchs_start_indexes
declare -A _orb_declared_catchs_lengths
