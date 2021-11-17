declare -A _orb_settings=(
  # from input
  ['--help']='false'
  ['-d']='false'
  ['-r']='false'
  # Internal
  ['call']='false'
)

[[ $1 == 'call' ]] && _orb_settings['call']=true
