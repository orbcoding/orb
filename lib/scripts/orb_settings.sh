declare -A _orb_settings=(
  # from input
  ['--help']='false'
  ['-d']='false'
  ['-r']='false'
  # Internal
  ['call']='false'
  ['namespace_help']='false'
)

[[ $1 == 'call' ]] && _orb_settings['call']=true
