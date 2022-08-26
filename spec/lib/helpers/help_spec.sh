Include lib/helpers/help.sh
Include lib/utils/utils.sh

# _orb_handle_help_requested
Describe '_orb_handle_help_requested'
  _orb_print_global_namespace_help_intro() { echo_fn; }
  _orb_print_namespace_help() { echo_fn; }
  _orb_setting_namespace_help=false
  _orb_setting_global_help=false

  It 'prints global help if global help requested'
    _orb_setting_global_help=true
    When call _orb_handle_help_requested
    The output should equal _orb_print_global_namespace_help_intro
  End

  It 'prints namespace help if namespace help requested'
    _orb_setting_namespace_help=true
    When call _orb_handle_help_requested
    The output should equal _orb_print_namespace_help
  End

  It 'fails when no help requested'
    When call _orb_handle_help_requested
    The status should be failure
  End
End


# _orb_print_global_namespace_help_intro
Describe '_orb_print_global_namespace_help_intro'
  Include lib/utils/text.sh
  
  It 'prints help with no namespaces or default'
    When call _orb_print_global_namespace_help_intro
    The output should equal 'Default namespace $ORB_DEFAULT_NAMESPACE not set.

No namespaces found'
  End

  It 'prints default namespace if found'
    ORB_DEFAULT_NAMESPACE=spec
    When call _orb_print_global_namespace_help_intro
    The output should equal "Default namespace: $(orb_bold)$ORB_DEFAULT_NAMESPACE$(orb_normal).

No namespaces found"
  End

  It 'prints namespaces when found'
    _orb_namespaces=( spec spec2 )
    When call _orb_print_global_namespace_help_intro
    The output should equal 'Default namespace $ORB_DEFAULT_NAMESPACE not set.

Available namespaces listed below:

  spec, spec2.

To list commands in a namespace, use `orb "namespace" --help`'
  End
End

# _orb_print_namespace_help
Describe '_orb_print_namespace_help'

End

# _orb_print_function_help
Describe '_orb_print_function_help'
End

# _orb_print_args_explanation
Describe '_orb_print_args_explanation'
End

# _orb_print_function_comment
Describe '_orb_print_function_comment'
End

# _orb_print_orb_function_and_comment
Describe '_orb_print_orb_function_and_comment'
End
