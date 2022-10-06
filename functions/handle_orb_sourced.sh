_orb_is_sourced_by_unhandled_fn() {
  [[ ${_orb_function_trace[0]} == "source" ]] && \
  [[ ${_orb_function_trace[2]} != "orb" ]]
}
