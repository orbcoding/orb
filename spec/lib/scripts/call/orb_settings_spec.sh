_orb_dir=$(pwd)
Include lib/scripts/initialize.sh
Include lib/scripts/call/variables.sh

Describe 'orb_settings.sh'
  orb_raise_error() { echo "$@"; exit 1; }

  It 'collects --help'
    When call source lib/scripts/call/orb_settings.sh --help
    The variable "_orb_settings_help" should equal true
    The status should equal 1
  End

  It 'collects --d'
    When call source lib/scripts/call/orb_settings.sh -d
    The variable "_orb_settings_direct_call" should equal true
    The status should equal 1
  End
  
  It 'collects -r'
    When call source lib/scripts/call/orb_settings.sh -r
    The variable "_orb_settings_reload_functions" should equal true
    The status should equal 1
  End

  It 'collects -e'
    When call source lib/scripts/call/orb_settings.sh -e spec_ext -e spec_ext2
    The variable "_orb_settings_extensions[0]" should equal "spec_ext"
    The variable "_orb_settings_extensions[1]" should equal "spec_ext2"
    The status should equal 4
  End

  It 'returns number of steps to shift'
    When call source lib/scripts/call/orb_settings.sh -e spec_ext -e spec_ext2 -r --help
    The status should equal 6
  End
End
