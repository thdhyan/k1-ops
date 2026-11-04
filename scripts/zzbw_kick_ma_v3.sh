#!/bin/bash
# On zz-bw, in tmux kma3: 2-robot pass-and-shoot, robot_b in goal half facing goal, robot_a released to walk base after kick, warm-started from kick_ma_v2.
Z=/export/scratch/thakk100/k1_mjlab
cd $Z/mjlab || exit 1
export CUDA_VISIBLE_DEVICES=0 WANDB_MODE=disabled MUJOCO_GL=egl K1_KMA_BASE=$Z/base/walk_still_v4.pt
.venv/bin/k1-train Mjlab-KickMA-Booster-K1 --env.scene.num-envs 4096 --agent.run-name kick_ma_v3 --agent.logger tensorboard \
  --agent.max-iterations 6000 --agent.save-interval 200 --agent.resume True --agent.load-run '.*kick_ma_v2' \
  --agent.load-checkpoint 'model_.*' > $Z/kick_ma_v3.log 2>&1
echo KMA3_DONE
