Include lib/helpers/extensions.sh
Include lib/utils/file.sh

Describe 'orb_extensions.sh'
  It 'Collects orb extensions and parses their .env files'
    When call source lib/scripts/source/extensions.sh
    The variable _orb_extensions should be defined
  End

  It 'Collects orb extensions and parses their .env files'
    _orb_collect_orb_extensions() { echo_me;}
    _orb_parse_env_extensions() { echo_me;}
    When call source lib/scripts/source/extensions.sh
    The output should equal "_orb_collect_orb_extensions
_orb_parse_env_extensions"
  End
End
