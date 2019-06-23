#!/bin/bash

set -e

## call find_bot to init this
window_id=

## This is the small sleep between key presses. Change for debugging
## when you are not sure what is happening
echo arg is $1
if [ -z $1 ]
then
    small_sleep=0.1
else
    small_sleep=$1
fi

big_sleep=1

emacs_process_pid=

function sleep_small {
    sleep $small_sleep
}

function sleep_big {
    sleep $big_sleep
}

function send_answer {
    retn
    sleep_small
    key 5
    sleep_small
}

function launch_emacs {
    echo Launching $EMACS -Q -l $* &

    $EMACS -Q -l $* &
    emacs_process_pid=$!
}

function kill_emacs {
    key alt+x
    command kill-emacs
    retn
}

function xdo {
    xdotool $1 --window $window_id $2 || {
        echo "Failed command: $1, $2";exit 1
    }
}
function key {
    xdo key $1
}

function command {
    xdo type $1
}

function retn {
    key Return
}

function wait_emacs {
    wait $emacs_process_pid || exit 1
}

function find_bot {
    for i in `seq 1 40`;
    do
        window_id=`xdotool search --onlyvisible --name "emacs-bot" 2> /dev/null`
        if [ -z "$window_id" ]
        then
            sleep 0.1
        else
            echo "Found Emacs-Bot on $i-th poll"
            return
        fi
    done
    echo "Could not find window ID for Emacs-bot"
    exit 1
}
