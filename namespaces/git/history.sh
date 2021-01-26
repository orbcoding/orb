declare -A forget_args=(
  ['1']='file to forget'
); function forget() { # Completely forget file from local branch history (with confirmation prompt)
	validate_is_repo
	if [ -e "$1" ]; then
		echo -n "Forget $1? y/n: "
		local reply
		read reply
	else
		orb -c utils raise_error +t "file not found"
		echo 'file not found'
		exit 1
	fi;

	if [[ $reply == 'y' ]]; then
		echo "Forgetting ${path}"
		git filter-branch --index-filter "git rm -rf --cached --ignore-unmatch ${path}" HEAD
	fi
}

function validate_is_repo() {
	local validate_is_repo=$([ -d .git ] && echo .git || git rev-parse --git-dir > /dev/null 2>&1)
	[[ -z "$validate_is_repo" ]] && orb -c utils raise_error 'not in git repo'
}
