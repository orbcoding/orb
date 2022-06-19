source "$_orb_dir/lib/utils/orb_pass.sh"
source "$_orb_dir/lib/utils/argument.sh"
source "$_orb_dir/lib/utils/debug.sh"
source "$_orb_dir/lib/utils/error.sh"
source "$_orb_dir/lib/utils/file.sh"
source "$_orb_dir/lib/utils/text.sh"
source "$_orb_dir/lib/utils/utils.sh"

source "$_orb_dir/lib/helpers/extensions.sh"
source "$_orb_dir/lib/helpers/help.sh"
source "$_orb_dir/lib/helpers/call/preparation.sh"
source "$_orb_dir/lib/helpers/declaration/general.sh"
source "$_orb_dir/lib/helpers/declaration/argument_options.sh"

source "$_orb_dir/lib/arguments/assignment.sh"
source "$_orb_dir/lib/arguments/collection.sh"
source "$_orb_dir/lib/declaration/arguments.sh"
source "$_orb_dir/lib/declaration/argument_options.sh"
source "$_orb_dir/lib/arguments/defaults.sh"
source "$_orb_dir/lib/arguments/options.sh"
source "$_orb_dir/lib/arguments/validation.sh"


declare -n _orb_function_trace=$(_orb_get_function_trace)
declare -n _orb_source_trace=$(_orb_get_source_trace)
