#!/bin/bash
# Laptop: returns when both PushIK v10 and walk_still_v4 queues have ended (tmux sessions gone).
C=~/.ssh/config.good-20261027
while ssh -F $C zz-bw "tmux has-session -t pik10" 2>/dev/null || ssh -F $C -J zz-bw dl "tmux has-session -t walk4" 2>/dev/null; do sleep 300; done
echo BOTH_ENDED
