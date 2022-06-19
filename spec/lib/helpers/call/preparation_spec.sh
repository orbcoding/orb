Include lib/helpers/call/preparation.sh
Include lib/utils/text.sh

Describe '_orb_get_current_namespace'
  _orb_get_current_namespace_from_args() { echo_me && return 3; }
  _orb_get_current_namespace_from_file_structure() { echo_me; }

  Context 'without _orb_setting_sourced'
    _orb_setting_sourced=false

    It 'echoes output and returns status of _orb_get_current_namespace_from_args'
      When run _orb_get_current_namespace
      The status should equal 3
      The output should equal _orb_get_current_namespace_from_args
    End
  End

  Context 'with _orb_setting_sourced'
    _orb_setting_sourced=true

    It 'echoes output of _orb_get_current_namespace_from_file_structure and returns 1'
      When run _orb_get_current_namespace
      The status should equal 2
      The output should equal _orb_get_current_namespace_from_file_structure
    End
  End
End


Describe '_orb_get_current_namespace_from_args'
  _orb_namespaces=( test_namespace )

  Context 'when namespace defined'
    It 'returns first argument as namespace'
      When call _orb_get_current_namespace_from_args test_namespace 1 2
      The status should be success
      The output should equal test_namespace
    End
  End

  Context 'when namespace undefined'
    Context 'when $ORB_DEFAULT_NAMESPACE defined'
      ORB_DEFAULT_NAMESPACE=def_space

      It 'returns $ORB_DEFAULT_NAMESPACE'
        When call _orb_get_current_namespace_from_args hello 1 2
        The status should equal 2
        The output should equal def_space
      End
    End

    Context 'without $ORB_DEFAULT_NAMESPACE'
      It 'raises error unless _orb_setting_global_help'
        orb_raise_error() { echo_me && exit 1; }
        _orb_setting_global_help=false
        When run _orb_get_current_namespace_from_args hello 1 2
        The status should equal 1
        The output should equal orb_raise_error
      End

      It 'succeeds if _orb_setting_global_help'
        _orb_setting_global_help=true
        When run _orb_get_current_namespace_from_args hello 1 2
        The status should be success
      End
    End
  End
End


Describe '_orb_get_current_namespace_from_file_structure'
  It 'can get namespace from filename'
    _orb_get_current_sourcer_file_path() { echo namespaces/test_namespace.sh; }
    When call _orb_get_current_namespace_from_file_structure
    The status should be success
    The output should equal test_namespace
  End

  It 'can get namespace from nested files dirname'
    _orb_get_current_sourcer_file_path() { echo namespaces/test_namespace/nest_file.sh; }
    When call _orb_get_current_namespace_from_file_structure
    The status should be success
    The output should equal test_namespace
  End

  It 'fails if not found'
    _orb_get_current_sourcer_file_path() { echo random_dir/test_namespace/nest_file.sh; }
    When call _orb_get_current_namespace_from_file_structure
    The status should be failure
  End
End


Describe _orb_get_current_function
  Context 'with _orb_setting_sourced'
    _orb_setting_sourced=true
    _orb_get_current_function_from_source_chain() { echo_me; }

    It 'calls _orb_get_current_function_from_source_chain and returns 2'
      When call _orb_get_current_function my_function
      The status should equal 2
      The output should equal _orb_get_current_function_from_source_chain
    End
  End

  Context 'without _orb_setting_sourced'
    _orb_setting_sourced=false

    It 'returns 0 and outputs $1'
      When call _orb_get_current_function my_function
      The status should be success
      The output should equal my_function
    End
  End
End


Describe '_orb_get_current_sourcer_file_path'
  declare -n _orb_source_trace=$(_orb_get_source_trace)

  It 'gets path of sourcer file'
    When run source spec/templates/proxy.sh source $spec_orb/orb/bin/orb _orb_get_current_sourcer_file_path
    The output should equal spec/templates/proxy.sh
  End
End

Describe '_orb_get_current_function_from_source_chain'
  declare -n _orb_function_trace=$(_orb_get_function_trace)

  It 'gets function from source chain'
    # Double source as orb sources again internally
    When run source spec/templates/proxy.sh source spec/templates/proxy.sh source $spec_orb/orb/bin/orb _orb_get_current_function_from_source_chain
    The output should equal proxy_fn
  End
End


Describe '_orb_get_current_function_descriptor'
  It 'includes namespace if present'
    When run _orb_get_current_function_descriptor test_fn test_namespace
    The output should equal "test_namespace->$(orb_bold)test_fn$(orb_normal)"
  End

  It 'only fn if no namespace'
    When run _orb_get_current_function_descriptor test_fn
    The output should equal $(orb_bold)test_fn$(orb_normal)
  End
End


Describe '_orb_get_function_trace'
  It 'prints function trace variable'
    When call _orb_get_function_trace
    The output should equal FUNCNAME
  End
End


Describe '_orb_get_source_trace'
  It 'prints source trace variable'
    When call _orb_get_source_trace
    The output should equal BASH_SOURCE
  End
End
