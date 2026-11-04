#!/bin/bash
# On dl: one residual training. Usage: dl_skills_v2.sh <gpu> <kick|steps|carry|kick2|kickdir|jump> [jump run name] [jump iters] [jump run to resume]
# Frozen bases: walk_still_v4 (kick, carry), rough_walk_v2 (steps). Videos every 500 iters of 24 steps.
cd ~/k1_mjlab/mjlab || exit 1
B=$HOME/k1_mjlab/base
export MUJOCO_GL=egl CUDA_VISIBLE_DEVICES=$1 WANDB_MODE=disabled
V="--video True --video-interval 12000 --video-length 400 --agent.logger tensorboard --agent.save-interval 200"
case $2 in
  kick)  K1_BASE_CKPT=$B/walk_still_v4.pt K1_KICK_RESIDUAL=1 .venv/bin/k1-train Mjlab-Kick-Booster-K1 --env.scene.num-envs 4096 \
           --agent.run-name kick_res_v1 --agent.max-iterations 6000 $V > ../kick_res_v1.log 2>&1 ;;
  steps) K1_STEPS_BASE_CKPT=$B/rough_walk_v2.pt K1_BASE_CKPT=$B/walk_still_v4.pt .venv/bin/k1-train Mjlab-Steps-Booster-K1 --env.scene.num-envs 4096 \
           --agent.run-name steps_res_v2 --agent.max-iterations 6000 $V > ../steps_res_v2.log 2>&1 ;;
  carry) K1_BASE_CKPT=$B/walk_still_v4.pt K1_CV_BASE=$B/walk_still_v4.pt .venv/bin/k1-train Mjlab-CarryVel-Booster-K1 --env.scene.num-envs 4096 \
           --agent.run-name carry_vel_v1 --agent.max-iterations 6000 $V > ../carry_vel_v1.log 2>&1 ;;
  kick2) K1_BASE_CKPT=$B/walk_still_v4.pt K1_KICK_RESIDUAL=1 K1_KICK_GATE=1 K1_KICK_CMD_ALPHA=0.3 .venv/bin/k1-train Mjlab-Kick-Booster-K1 --env.scene.num-envs 4096 \
           --agent.run-name kick_res_v2 --agent.max-iterations 6000 $V > ../kick_res_v2.log 2>&1 ;;
  kickdir) K1_BASE_CKPT=$B/walk_still_v4.pt K1_KICK_RESIDUAL=1 K1_KICK_GATE=1 K1_KICK_CMD_ALPHA=0.3 .venv/bin/k1-train Mjlab-KickDir-Booster-K1 --env.scene.num-envs 4096 \
           --agent.run-name kick_dir_v1 --agent.max-iterations 6000 --agent.resume True --agent.load-run warm_kick_res_v2 $V > ../kick_dir_v1.log 2>&1 ;;
  jump)  K1_BASE_CKPT=$B/walk_still_v4.pt .venv/bin/k1-train Mjlab-Jump-Booster-K1 --env.scene.num-envs 4096 \
           --agent.run-name ${3:-jump_v1} --agent.max-iterations ${4:-6000} ${5:+--agent.resume True --agent.load-run $5} $V > ../${3:-jump_v1}.log 2>&1 ;;
esac
echo "$2 DONE"
