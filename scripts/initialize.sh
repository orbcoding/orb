source "$_orb_dir/functions/utils/pass.sh"
source "$_orb_dir/functions/utils/argument.sh"
source "$_orb_dir/functions/utils/debug.sh"
source "$_orb_dir/functions/utils/error.sh"
source "$_orb_dir/functions/utils/file.sh"
source "$_orb_dir/functions/utils/text.sh"
source "$_orb_dir/functions/utils/utils.sh"

source "$_orb_dir/functions/source/extensions.sh"
source "$_orb_dir/functions/call/orb_settings.sh"
source "$_orb_dir/functions/call/preparation.sh"
source "$_orb_dir/functions/help.sh"

source "$_orb_dir/functions/declaration/function.sh"
source "$_orb_dir/functions/declaration/arguments.sh"
source "$_orb_dir/functions/declaration/argument_options.sh"
source "$_orb_dir/functions/declaration/checkers.sh"
source "$_orb_dir/functions/declaration/validation.sh"
source "$_orb_dir/functions/declaration/orb_settings_declaration.sh"

source "$_orb_dir/functions/arguments/assignment.sh"
source "$_orb_dir/functions/arguments/collection.sh"
source "$_orb_dir/functions/arguments/validation.sh"
source "$_orb_dir/functions/arguments/checkers.sh"


declare -n _orb_function_trace=$(_orb_get_function_trace)
declare -n _orb_source_trace=$(_orb_get_source_trace)
