_orb_root=$(pwd)
Include scripts/initialize.sh
Include scripts/call/variables.sh

Describe 'settings.sh'
  _orb_raise_error() { echo "$@"; exit 1; }

  It 'collects --help'
    When call source scripts/call/settings.sh --help
    The variable "_orb_setting_help" should equal true
    The variable "_orb_settings_args[@]" should eq "--help"
  End

  It 'collects --d'
    When call source scripts/call/settings.sh -d
    The variable "_orb_setting_direct_call" should equal true
    The variable "_orb_settings_args[@]" should eq "-d"
  End
  
  It 'collects -r'
    When call source scripts/call/settings.sh -r
    The variable "_orb_setting_reload_functions" should equal true
    The variable "_orb_settings_args[@]" should eq "-r"
  End

  It 'collects -e'
    When call source scripts/call/settings.sh -e spec_ext -e spec_ext2
    The variable "_orb_setting_extensions[0]" should equal "spec_ext"
    The variable "_orb_setting_extensions[1]" should equal "spec_ext2"
    The variable "_orb_settings_args[@]" should eq "-e spec_ext -e spec_ext2"
  End

  It 'adds collected extensions to _orb_extensions array'
    _orb_extensions=("some/ext")
    When call source scripts/call/settings.sh -e spec_ext -e spec_ext2
    The variable "_orb_extensions[0]" should equal "some/ext"
    The variable "_orb_extensions[1]" should equal "spec_ext"
    The variable "_orb_extensions[2]" should equal "spec_ext2"
    The variable "_orb_settings_args[@]" should eq "-e spec_ext -e spec_ext2"
  End
End
