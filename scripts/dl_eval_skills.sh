#!/bin/bash
# On dl: evals of the three residual skills, then kick episodes for the RTX replay.
cd ~/k1_mjlab/mjlab || exit 1
B=$HOME/k1_mjlab/base; L=logs/rsl_rl; S=../mjlab_k1
export MUJOCO_GL=egl CUDA_VISIBLE_DEVICES=1 WANDB_MODE=disabled K1_BASE_CKPT=$B/walk_still_v4.pt
K=$L/k1_kick/2026-11-01_18-03-59_kick_res_v1/model_5999.pt
K1_KICK_RESIDUAL=1 .venv/bin/python $S/scripts_skill_eval.py Mjlab-Kick-Booster-K1 $K ../eval_kick_res_v1.json 2>&1 | grep -a EVAL
K1_KICK_RESIDUAL=1 .venv/bin/python $S/scripts_kick_record.py $K ../kick_res_v1_rec.npz 3 2>&1 | grep -a -E "walk-up|only"
K1_STEPS_BASE_CKPT=$B/rough_walk_v2.pt .venv/bin/python $S/scripts_skill_eval.py Mjlab-Steps-Booster-K1 $L/k1_steps/2026-11-01_18-03-59_steps_res_v2/model_5999.pt ../eval_steps_res_v2.json 2>&1 | grep -a EVAL
K1_CV_BASE=$B/walk_still_v4.pt .venv/bin/python $S/scripts_skill_eval.py Mjlab-CarryVel-Booster-K1 $L/k1_carry_vel/2026-11-01_18-03-59_carry_vel_v1/model_5999.pt ../eval_carry_vel_v1.json 2>&1 | grep -a EVAL
gzip -f ../carry_vel_v1.log
echo EVAL_DONE
