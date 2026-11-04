#!/bin/bash
# On zz-bw, in tmux kma1: 2-robot pass-and-shoot (Mjlab-KickMA-Booster-K1), warm-started from kick_dir_v1.
Z=/export/scratch/thakk100/k1_mjlab
cd $Z/mjlab || exit 1
export CUDA_VISIBLE_DEVICES=0 WANDB_MODE=disabled MUJOCO_GL=egl K1_KMA_BASE=$Z/base/walk_still_v4.pt
.venv/bin/k1-train Mjlab-KickMA-Booster-K1 --env.scene.num-envs 4096 --agent.run-name kick_ma_v1 --agent.logger tensorboard \
  --agent.max-iterations 6000 --agent.save-interval 200 --agent.resume True --agent.load-run '.*kick_ma_init' \
  --agent.load-checkpoint model_0.pt > $Z/kick_ma_v1.log 2>&1
echo KMA1_DONE
