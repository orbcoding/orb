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


_orb_call_0_declared_vars 
_orb_call_0_declared_args 
_orb_call_0_declared_arg_suffixes
_orb_call_0_declared_arg_requireds
_orb_call_0_declared_arg_ins
_orb_call_0_declared_arg_defaults
