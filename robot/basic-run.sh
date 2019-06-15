#!/bin/bash

set -e

function run_drill {
    ## Org-drill should be running at this point, so give three answers
    ## with a score of file
    sleep_big

    echo answer one
    send_answer

    echo answer two
    send_answer

    echo answer three
    send_answer

    ## Press any key to continue
    echo press any key to continue
    retn
    sleep_small

    echo Save file
    key y
}

this_dir="$(dirname "$0")"
source $this_dir/robot.sh


launch_emacs $this_dir/basic-run.el

bsmall_sleep=5
big_sleep=10

{
    sleep 2
    find_bot

    ## Run once with default options
    run_drill

    ## Run once with presentation-prompt-with-typing
    run_drill

   # kill_emacs
} || cat robot/failure.txt
    $EMACS -Q -l $1 &
