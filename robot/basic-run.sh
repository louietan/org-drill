#!/bin/bash

set -e

function run_drill {
    ## Org-drill should be running at this point, so give three answers
    ## with a score of file
    sleep_small

    echo answer one
    send_answer

    echo answer two
    send_answer

    echo answer three
    send_answer

    ## Press any key to continue
    echo press any key to continue
    retn

    echo Save file
    key y
}

this_dir="$(dirname "$0")"
source $this_dir/robot.sh


launch_emacs $this_dir/basic-run.el

{
    find_bot

    ## Run once with default options
    run_drill

    ## Run once with presentation-prompt-with-typing
    run_drill

    wait_emacs
} || cat robot/failure.txt
