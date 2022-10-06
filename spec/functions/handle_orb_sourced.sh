Include functions/handle_orb_sourced.sh

Describe '_orb_is_sourced_by_unhandled_fn'
  It 'succeeds if sourced by function not called through orb'
    _orb_source_trace=(source fn not_orb)
    When call _orb_is_sourced_by_unhandled_fn
    The status should be success
  End
  
  It 'fails if sourced by function called through orb'
    _orb_source_trace=(source fn orb)
    When call _orb_is_sourced_by_unhandled_fn
    The status should be failure
  End
  
  It 'fails if not sourced'
    _orb_source_trace=(fn other_fn orb)
    When call _orb_is_sourced_by_unhandled_fn
    The status should be failure
  End
End
