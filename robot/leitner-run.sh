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
}

this_dir="$(dirname "$0")"
source $this_dir/robot.sh

##small_sleep=3

launch_emacs $this_dir/leitner-run.el

{
    sleep 1
    find_bot

    ## Run once with default options
    run_drill

    wait_emacs
} || cat robot/failure.txt
