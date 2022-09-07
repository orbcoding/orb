Include functions/call/extensions.sh
Include functions/utils/file.sh


Describe '_orb_collect_orb_extensions'
  _orb_extensions=()

  It 'calls nested functions with correct params'
    orb_upfind_to_arr() { :; }
    orb_trim_uniq_realpaths() { :; }
    # so no home .orb is found
    HOME=
    orb_upfind_to_arr() { spec_args+=($(echo_fn "$@")); }
    orb_trim_uniq_realpaths() { spec_args+=($(echo_fn "$@")); }
    When call _orb_collect_orb_extensions start last
    The variable "spec_args[@]" should equal "orb_upfind_to_arr _orb_extensions _orb&.orb start last orb_trim_uniq_realpaths _orb_extensions _orb_extensions"
    The variable "_orb_extensions[0]" should be undefined
  End

  It 'includes .orb from home dir if present'
    HOME=$(pwd)/spec/fixtures
    cd /
    When call _orb_collect_orb_extensions
    The variable "_orb_extensions[0]" should eq "$HOME/.orb"
    The variable "_orb_extensions[1]" should be undefined
  End

  It 'finds _orb and .orb folders'
    cd spec/fixtures
    When call _orb_collect_orb_extensions
    The variable "_orb_extensions[0]" should eq $(pwd)/_orb
    The variable "_orb_extensions[1]" should eq $(pwd)/.orb
  End
End


Describe '_orb_collect_namespaces'
  It 'finds namespaces in orb folders'
    _orb_extensions=( spec/fixtures/_orb_extension  )
    When call _orb_collect_namespaces
    The variable "_orb_namespaces[0]" should equal spec_extensions
    The variable "_orb_namespaces[1]" should be undefined
  End

  It 'adds each once'
    _orb_extensions=( spec/fixtures/_orb_extension spec/fixtures/_orb_extension )
    When call _orb_collect_namespaces
    The variable "_orb_namespaces[0]" should equal spec_extensions
    The variable "_orb_namespaces[2]" should be undefined
  End

  It 'adds from multiple folders'
    _orb_extensions=( spec/fixtures/_orb_extension spec/fixtures/_orb_extension2 )
    When call _orb_collect_namespaces
    The variable "_orb_namespaces[0]" should equal spec_extensions
    The variable "_orb_namespaces[1]" should equal spec_extensions2
    The variable "_orb_namespaces[2]" should be undefined
  End
End


Describe '_orb_parse_env_extensions'
  Include functions/utils/file.sh
  It 'parses env files in orb folders'
    _orb_extensions=( spec/fixtures/.orb spec/fixtures/_orb )
    When call _orb_parse_env_extensions
    The variable SPEC_TEST_VAR should equal "test"
    The variable SPEC_TEST_VAR3 should equal "test3"
  End
End

Describe '_orb_collect_namespace_files'
  It 'collects namespaces files'
    _orb_namespace=spec_extensions
    _orb_extensions=( spec/fixtures/_orb_extension spec/fixtures/_orb_extension2 )

    When call _orb_collect_namespace_files
    The variable "_orb_namespace_files[0]" should equal spec/fixtures/_orb_extension/namespaces/spec_extensions.sh
    The variable "_orb_namespace_files[1]" should equal spec/fixtures/_orb_extension2/namespaces/spec_extensions/spec_extensions2.sh
    The variable "_orb_namespace_files[2]" should equal spec/fixtures/_orb_extension2/namespaces/spec_extensions/spec_extensions.sh
    The variable "_orb_namespace_files[3]" should be undefined
  End
End
