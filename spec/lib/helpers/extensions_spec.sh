Include lib/helpers/source/extensions.sh
Include lib/utils/file.sh


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
    HOME=$(pwd)/spec/templates
    cd /
    When call _orb_collect_orb_extensions
    The variable "_orb_extensions[0]" should eq "$HOME/.orb"
    The variable "_orb_extensions[1]" should be undefined
  End

  It 'finds _orb and .orb folders'
    cd spec/templates
    When call _orb_collect_orb_extensions
    The variable "_orb_extensions[0]" should eq $(pwd)/_orb
    The variable "_orb_extensions[1]" should eq $(pwd)/.orb
  End
End


Describe '_orb_collect_namespace_extensions'
  It 'finds namespaces in orb folders'
    _orb_extensions=( spec/templates/.orb )
    When call _orb_collect_namespace_extensions
    The variable "_orb_namespaces[0]" should equal spec
    The variable "_orb_namespaces[1]" should equal spec2
    The variable "_orb_namespaces[2]" should be undefined
  End

  It 'adds each once'
    _orb_extensions=( spec/templates/.orb spec/templates/.orb )
    When call _orb_collect_namespace_extensions
    The variable "_orb_namespaces[0]" should equal spec
    The variable "_orb_namespaces[1]" should equal spec2
    The variable "_orb_namespaces[2]" should be undefined
  End

  It 'adds from multiple folders'
    _orb_extensions=( spec/templates/.orb spec/templates/_orb )
    When call _orb_collect_namespace_extensions
    The variable "_orb_namespaces[0]" should equal spec
    The variable "_orb_namespaces[1]" should equal spec2
    The variable "_orb_namespaces[2]" should equal spec3
    The variable "_orb_namespaces[3]" should be undefined
  End
End


Describe '_orb_parse_env_extensions'
  Include lib/utils/file.sh
  It 'parses env files in orb folders'
    _orb_extensions=( spec/templates/.orb spec/templates/_orb )
    When call _orb_parse_env_extensions
    The variable SPEC_TEST_VAR should equal "test"
    The variable SPEC_TEST_VAR3 should equal "test3"
  End
End

Describe '_orb_collect_namespace_files'
  It 'collects namespaces files'
    _orb_namespace="spec"
    _orb_extensions=( spec/templates/.orb spec/templates/_orb )

    When call _orb_collect_namespace_files
    The variable "_orb_namespace_files[0]" should equal spec/templates/.orb/namespaces/spec/test_functions.sh
    The variable "_orb_namespace_files[1]" should equal spec/templates/_orb/namespaces/spec.sh
    The variable "_orb_namespace_files[2]" should be undefined
  End
End
