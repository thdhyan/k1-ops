#!/bin/bash
# Run on the laptop, any time, any number of times. Prints queue status, then copies whatever PushIK v8/v9 outputs exist
# on zz-bw to the local renders dir, the final checkpoints to models/mjlab_k1/, and the videos and evals to Drive.
set -u
ROOT=$(cd "$(dirname "$0")/.." && pwd)
C=~/.ssh/config.good-20261027
Z=/export/scratch/thakk100/k1_mjlab
R=$ROOT/models/mjlab_k1/renders
DRIVE="gdrive-thakk100:K1 PushIK + Walk v3 2026-10-31/push_ik/"
quiet() { grep -v "bind \[\|channel_setup\|Could not request"; }

ssh -F $C zz-bw "tmux ls 2>/dev/null | cut -d: -f1 | tr '\n' ' '; echo
  for v in 8 9; do [ -f $Z/push_ik_v\$v.log ] && echo v\$v \$(grep -a 'Learning iteration' $Z/push_ik_v\$v.log | tail -1 | sed 's/\x1b\[[0-9;]*m//g') \$(grep -a 'ETA' $Z/push_ik_v\$v.log | tail -1); done
  grep -a 'POST_DONE' $Z/post_v8.log; grep -a 'GRID_DONE' $Z/grid8.log; grep -a 'V9_DONE' $Z/q9.log; true" 2>&1 | quiet

for f in push_v8_sizes.mp4 push_v8_grid16.mp4 push_v9_grid16.mp4 eval_v8.json eval_v9.json; do
  ssh -F $C zz-bw "test -s $Z/$f" 2>/dev/null || { echo "missing $f"; continue; }
  # the file may still be being written until its job ends: only take it once its size is stable
  a=$(ssh -F $C zz-bw "stat -c %s $Z/$f" 2>/dev/null); sleep 20; b=$(ssh -F $C zz-bw "stat -c %s $Z/$f" 2>/dev/null)
  [ "$a" = "$b" ] || { echo "still writing $f"; continue; }
  rsync -a -e "ssh -F $C" zz-bw:$Z/$f "$R/" 2>&1 | quiet
  rclone copy "$R/$f" "$DRIVE" && echo "uploaded $f"
done

for v in 8 9; do
  run=$(ssh -F $C zz-bw "ls -d $Z/mjlab/logs/rsl_rl/k1_push_ik/*_push_ik_v$v 2>/dev/null | tail -1" 2>/dev/null)
  [ -n "$run" ] || continue
  # a checkpoint is final only after the tmux session that trains it has gone
  sess=pik8; [ $v = 9 ] && sess=q9
  ssh -F $C zz-bw "tmux has-session -t $sess" 2>/dev/null && { echo "v$v still running, model not copied"; continue; }
  ck=$(ssh -F $C zz-bw "ls $run | grep -E '^model_[0-9]+\.pt$' | sort -t_ -k2 -n | tail -1" 2>/dev/null)
  mkdir -p "$ROOT/models/mjlab_k1/push_ik_v$v"
  rsync -a -e "ssh -F $C" "zz-bw:$run/$ck" "$ROOT/models/mjlab_k1/push_ik_v$v/" 2>&1 | quiet
  echo "model v$v: models/mjlab_k1/push_ik_v$v/$ck"
done
