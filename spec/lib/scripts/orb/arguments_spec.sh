Include lib/utils/argument.sh
Include lib/utils/text.sh

Describe 'orb_arguments.sh'
  orb_raise_error() { echo -e "$@" && exit 1; }

  It 'parses arguments'
    When run source lib/scripts/orb_arguments.sh --unknown-flag
    The output should equal "-d $(orb_bold)orb$(orb_normal) invalid option --unknown-flag

Available options:

  --help   show help
  -d       direct function call
  -r       restore function declarations after call"

    The status should be failure
  End
End
