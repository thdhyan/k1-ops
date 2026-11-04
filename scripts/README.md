# scripts

Part of [k1-ops](https://github.com/thdhyan/k1-ops).

| File | What it does |
|---|---|
| `chain_p4_p2_host.sh` | Wait for the P4 kick-teacher full run to pass its gate, then launch the P2 |
| `chain_train.sh` | chain_train.sh — run inside tmux: wait for session $1 to end, then execute |
| `diag_frozen.sh` | Frozen-base diagnostic (inside the Isaac image) — two passes: |
| `dl_ab_push_frict_host.sh` | Track B A/B hunt step C (dl, GPU 2): ground-friction parity re-gate. |
| `dl_ab_push_stiff_host.sh` | Track B A/B hunt step D (dl, GPU 2): stiff-arms test of the frozen base. |
| `dl_ab_push_wiring_host.sh` | Track B A/B hunt step E (dl, GPU 2): joint-wiring FIX re-gate. |
| `dl_eval_skills.sh` | On dl: evals of the three residual skills, then kick episodes for the RTX replay. |
| `dl_k1_teleop_up.sh` | Build / start / stop the K1 VR teleop stack on dl (sim + Quest XR node + YOLO). |
| `dl_push_base_resume_host.sh` | Host launcher (dl, GPU 1): Track B gait-v2 base RESUME training in tmux+docker |
| `dl_push_chain2_host.sh` | Auto-chain AFTER the dl base RESUME — v2 (corrected gates). |
| `dl_push_chain3_host.sh` | Auto-chain reach -> push (host side, dl; detached): |
| `dl_push_chain_host.sh` | Auto-chain AFTER the dl base RESUME (host side, dl; run inside tmux): |
| `dl_push_host.sh` | Push host launcher for dl (run on dl): reach / push |
| `dl_record_push_host.sh` | P6 play+record host wrapper (dl, GPU 2 = pinned record/eval GPU). |
| `dl_skills_v2.sh` | On dl: one residual training. Usage: dl_skills_v2.sh <gpu> <kick/steps/carry/kick2/kickdir/jump> [jump run name] [jump iters] [jump run to r |
| `docker_isaac_fleet.sh` | Launch Isaac Sim Python standalone in Docker with X11 forwarding. |
| `install_phase6_env.sh` | Reproduce the Phase-6 environment from scratch (idempotent; ~30 GB, uv-cached). |
| `k1_launch_hrl.sh` | Start one HRL Stage-0 / skill training run on dl in tmux (run from the laptop). |
| `k1_train_status.sh` | Training status for the K1 boxes (run from the laptop). |
| `launch_dl_batch.sh` | Launch the dl parallel batch:  run ON dl  (ssh dl 'bash -s' < this). |
| `phase6_env.sh` | Phase-6 canonical training environment — Isaac Sim 6.1.0 + IsaacLab v3.0.0-EA. |
| `probe_rewards_host.sh` | Run the reward probe for one task inside the Isaac Lab container. |
| `push_base_chain_host.sh` | Auto-chain AFTER the gait-v2 base retrain (host side, spark04; run inside |
| `push_ik_fetch_upload.sh` | Run on the laptop, any time, any number of times. Prints queue status, then copies whatever PushIK v8/v9 outputs exist |
| `py_torch.sh` | Run any python in a torch-safe environment. |
| `record_p2_final_host.sh` | Wait server-side for the gait-v2 P2 final marker, record teacher+student, |
| `record_p2_one_host.sh` | Record + verify + upload ONE P2 policy (teacher, while the student trains). |
| `record_policies_host.sh` | REC host launcher (run on spark04): bind-mounts the staged repo + warp/kit |
| `remote_train.sh` | remote_train.sh: run an mjlab (k1-rl-mj) training on any SSH-reachable CUDA host. |
| `setup_remote.sh` | Idempotent Phase-6 bring-up on a REMOTE server box (dl, …). Run as the remote |
| `spark_force_host.sh` | F-variant host launcher (run on spark04): p1f/p2f — smoke-gated teacher PPO |
| `spark_full_host.sh` | Full-student host launcher (run on spark04): p1/p2. |
| `spark_p2_dispcheck_host.sh` | Wait for the P2 velocity-resume training to finish, then automatically run the |
| `spark_p2_gait_host.sh` | Host launcher for the revised P2 gait campaign on a GB10 Spark. |
| `spark_p2_gaitfix_host.sh` | Host launcher for the P2 gait-structured campaign. |
| `spark_p2_velcurriculum_host.sh` | Host launcher for the P2 velocity-curriculum campaign on a GB10 Spark. |
| `spark_p2_velresume_host.sh` | Host launcher for the P2 velocity resume: verify the checkpoint on video first, |
| `spark_partial_host.sh` | HP host launcher (run on spark02): bind-mounts the staged repo + warp/kit cache |
| `spark_probe.sh` | Spark python probe (container-side, fed via: docker run --entrypoint bash IMG -s < this). |
| `spark_probe2.sh` | Probe2 (container-side): map cartpole/Ant env ids -> registered RL config entry points. |
| `spark_probe3.sh` | Probe3 (container-side): how does this Isaac Lab image wire RL agent configs to tasks? |
| `spark_push_base_host.sh` | Host launcher (spark04): Track B frozen-base retrain on the gait-v2 velocity |
| `spark_push_host.sh` | Push host launcher (run on a spark): reach / push |
| `spark_s0_container.sh` | S0 (container-side): inventory + Kit headless boot + physics step probe on DGX Spark GB10. |
| `spark_s0_host.sh` | S0 host launcher (run on the spark): boots the S0 container smoke inside tmux. |
| `spark_s1_host.sh` | S1 host launcher (run on spark04): bind-mounts the staged repo + warp/kit cache and |
| `spark_s2_host.sh` | S2 host launcher (run on spark04): bind-mounts the staged repo + warp/kit cache and |
| `spark_soccer_host.sh` | Soccer host launcher (run on a spark): p3 / p4t |
| `spark_sync_loop.sh` | spark_sync_loop.sh — runs ON dl inside tmux k1_spark_sync. |
| `start_training.sh` | ============================================================ |
| `sweep_standing_host.sh` |  |
| `tmux_train.sh` | Launch a guarded training run inside a DETACHED tmux session so training |
| `track_a_recovery_host.sh` | Serialized recovery chain: P3 1900->1999, then gated P4, then gated P2. |
| `train_guard.sh` | train_guard.sh — run a training command under hard resource caps so the |
| `wait_skills.sh` | Laptop: wait until the dl residual trainings and the velocity grid end. |
| `wait_v10_v4.sh` | Laptop: returns when both PushIK v10 and walk_still_v4 queues have ended (tmux sessions gone). |
| `zzbw_kick_ma_v1.sh` | On zz-bw, in tmux kma1: 2-robot pass-and-shoot (Mjlab-KickMA-Booster-K1), warm-started from kick_dir_v1. |
| `zzbw_kick_ma_v2.sh` | On zz-bw, in tmux kma2: 2-robot pass-and-shoot with random layout and bbox head servo, warm-started from kick_ma_v1. |
| `zzbw_kick_ma_v3.sh` | On zz-bw, in tmux kma3: 2-robot pass-and-shoot, robot_b in goal half facing goal, robot_a released to walk base after kick, warm-started fro |
| `zzbw_kick_strike_v1.sh` | On zz-bw, in tmux kst1: directed kick teacher (Mjlab-KickStrike-Booster-K1), warm-started from kick_dir_v1. |
| `zzbw_push_chain_host.sh` | ============================================================================= |
| `zzbw_push_smoke.sh` | ============================================================================= |
