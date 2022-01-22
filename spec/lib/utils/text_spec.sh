Include lib/utils/text.sh

Describe 'orb_bold'
	It 'makes string bold'
    When call echo $(orb_bold)text
    The output should equal $(tput bold)text
  End
End

Describe 'orb_italic'
	It 'makes string italic'
    When call echo $(orb_italic)text
    The output should equal "\e[3mtext"
  End
End

Describe 'orb_underline'
	It 'makes string underlined'
    When call echo $(orb_underline)text
    The output should equal "\e[4mtext"
  End
End

Describe 'orb_red'
	It 'makes string red'
    When call echo $(orb_red)text
    The output should equal "\033[0;91mtext"
  End
End

Describe 'orb_green'
	It 'makes string green'
    When call echo $(orb_green)text
    The output should equal "\033[0;32mtext"
  End
End

Describe 'orb_normal'
	It 'normalizes string format'
    When call echo $(orb_normal)text
    The output should equal "$(tput sgr0)text"
  End
End

Describe 'orb_nocolor'
	It 'removes color from string'
    When call echo $(orb_nocolor)text
    The output should equal "\033[0mtext"
  End
End

Describe 'orb_upcase'
  It 'upcases text'
    When call orb_upcase text
    The output should equal TEXT
  End
End
