#!/bin/bash
# Default args
f_arg=0
r_arg=0
args=()
git_status_response=$(git status 2>&1)
is_git_repo=$(echo $git_status_response | grep -q fatal && echo 0 || echo 1)

function arg_help() {
    echo "\
    -f  = force/follow
    -r  = restart"
}

# Use function to check with echo
is_git_repo() {
	[[ $is_git_repo == '1' ]] || (
		echo 'Not git repo';
		exit 1
	)
}


args=()
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -f)
            f_arg=1
            shift # past argument
        ;;
        -r)
            r_arg=1
            shift # past argument
        ;;
        *)    # unknown option
            args+=("$1") # save it in an array for later
            shift # past argument
        ;;
    esac
done
