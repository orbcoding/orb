Include namespaces/core/text.sh

Describe '_bold'
	It 'makes string bold'
    When call echo $(_bold)text
    The output should equal $(tput bold)text
  End
End

Describe '_italic'
	It 'makes string italic'
    When call echo $(_italic)text
    The output should equal "\e[3mtext"
  End
End

Describe '_underline'
	It 'makes string underlined'
    When call echo $(_underline)text
    The output should equal "\e[4mtext"
  End
End

Describe '_red'
	It 'makes string red'
    When call echo $(_red)text
    The output should equal "\033[0;91mtext"
  End
End

Describe '_green'
	It 'makes string green'
    When call echo $(_green)text
    The output should equal "\033[0;32mtext"
  End
End

Describe '_normal'
	It 'normalizes string format'
    When call echo $(_normal)text
    The output should equal "$(tput sgr0)text"
  End
End

Describe '_nocolor'
	It 'removes color from string'
    When call echo $(_nocolor)text
    The output should equal "\033[0mtext"
  End
End

Describe '_upcase'
  It 'upcases text'
    When call _upcase text
    The output should equal TEXT
  End
End
