#!/bin/bash
# Laptop: wait until the dl residual trainings and the velocity grid end.
C=~/.ssh/config.good-20261027
while ssh -F $C -J zz-bw dl 'tmux ls 2>/dev/null' 2>/dev/null | grep -qE '^(kickres|stepsres|carryvel|gridcv):'; do sleep 300; done
echo SKILLS_ENDED
