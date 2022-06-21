# Instead of caller v2
_orb_call_count=0
_orb_call_trace_max_length=3 # min 1 needed for orb_pass
# 



if (( $_orb_call_count < $_orb_call_trace_max_length )); then
  trace_length=$_orb_call_count
  move_traces=$(( $trace_length - 1 ))
else
  trace_length=$_orb_call_trace_max_length
  destroy_trace_index=$(( $_orb_call_trace_max_length - 1 ))
fi


for trace in $(seq 0 $trace_length); do
  
done


# Namespace
_orb_namespace
_orb_function
_orb_function_descriptor
_orb_function_exit_code

_orb_declared_vars
_orb_declared_args
_orb_declared_suffixes

# No need
# _orb_declared_requireds
# _orb_declared_ins
# _orb_declared_defaults

_orb_args_values
_orb_args_values_indexes
_orb_args_values_lengths


# Becomes
_orb_args_values_history_0
