#!/bin/bash
# Default args
function_name=$1; shift
env="dev"
service="web"
f_arg=0
r_arg=0
args=()

set_env=0 # Track if user set manually
set_service=0

function arg_help() {
    echo "\
    -e  = env      (def=dev)
    -s  = service  (def=web)
    -f  = force/follow
    -r  = restart"
}

args=()
while [[ $# -gt 0 ]]
do
key="$1"

if [[ $function_name != 'runremote' ]]; then
    case $key in
        -e|--env)
            env="$2"
            set_env=1
            if [[ $env != 'prod' && $env != 'staging' && $env != 'dev' && $env != 'idle' ]]; then
                echo '-e not prod/staging/idle/dev'
                exit 1
            fi
            shift # past argument
            shift # past value
        ;;
        -s|--service)
            service="$2"
            set_service=1
            shift # past argument
            shift # past value
        ;;
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
else
    args+=("$1")
    shift
fi
done
