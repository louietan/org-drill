#!/bin/sh

set -e

$EMACS -Q -l ./robot/org-drill-launch.el &

sleep 1

window_id=`xdotool search --name "emacs-bot"`
if [ -z "$window_id" ]
then
    echo "Could not find window ID for Emacs-bot"
    exit 1
fi

## Org-drill should be running at this point, so give three answers
## with a score of file
echo answer one
xdotool key --window $window_id KP_Enter
sleep 0.25
xdotool key --window $window_id 5
sleep 0.25


echo answer two
xdotool key --window $window_id KP_Enter
sleep 0.25
xdotool key --window $window_id 5
sleep 0.25

echo answer three
xdotool key --window $window_id KP_Enter
sleep 0.25
xdotool key --window $window_id 5
sleep 0.25

# ## Press any key to continue
echo press any key to continue
xdotool key --window $window_id KP_Enter
sleep 0.25

echo Save file
xdotool key --window $window_id y
sleep 0.25

echo Goodnight Emacs
xdotool key --window $window_id alt+x
xdotool type --window $window_id kill-emacs
xdotool key --window $window_id KP_Enter
