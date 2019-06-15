#!/bin/bash

## call find_bot to init this
window_id=

## This is the small sleep between key presses. Change for debugging
## when you are not sure what is happening
small_sleep=0.25
big_sleep=1

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
    echo Launching $EMACS -Q -l $1 &
    $EMACS -Q -l $1 &
}

function kill_emacs {
    key alt+x
    command kill-emacs
    retn
}

function key {
    xdotool key --window $window_id $1
}

function command {
    xdotool type --window $window_id $1
}

function retn {
    xdotool key --window $window_id Return
}

function find_bot {
    window_id=`xdotool search --name "emacs-bot"`
    if [ -z "$window_id" ]
    then
        echo "Could not find window ID for Emacs-bot"
        exit 1
    fi
}
