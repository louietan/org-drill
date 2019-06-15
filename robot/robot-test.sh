#!/bin/bash

set -e

function run_drill {
    ## Org-drill should be running at this point, so give three answers
    ## with a score of file
    sleep 1
    echo answer one
    #xdotool type --window $window_id answer
    xdotool key --window $window_id Return
    sleep 0.25
    xdotool key --window $window_id 5
    sleep 0.25


    echo answer two
    #xdotool type --window $window_id answer
    xdotool key --window $window_id Return
    sleep 0.25
    xdotool key --window $window_id 5
    sleep 0.25

    echo answer three
    #xdotool type --window $window_id answer
    xdotool key --window $window_id Return
    sleep 0.25
    xdotool key --window $window_id 5
    sleep 0.25

    ## Press any key to continue
    echo press any key to continue
    xdotool key --window $window_id Return
    sleep 0.25

    echo Save file
    xdotool key --window $window_id y
}

function kill_emacs {
    echo Goodnight Emacs
    xdotool key --window $window_id alt+x
    xdotool type --window $window_id kill-emacs
    xdotool key --window $window_id KP_Enter
}

$EMACS -Q -l ./robot/org-drill-launch.el &

{
    sleep 2

    window_id=`xdotool search --name "emacs-bot"`
    if [ -z "$window_id" ]
    then
        echo "Could not find window ID for Emacs-bot"
        exit 1
    fi

    ## Run once with default options
    run_drill

    ## Run once with presentation-prompt-with-typing
    run_drill

    kill_emacs
} || cat robot/failure.txt
