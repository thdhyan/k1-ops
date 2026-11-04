# k1-ops

Host launchers, containers, CI, job chains.

| | |
|---|---|
| Layer | **L3**: Apps (processes you start) |
| May import | nothing |
| Files / LOC | 68 files · 2,479 lines (py, sh, cpp) |
| Part of | [k1-workspace](https://github.com/thdhyan/k1-workspace) (architecture and layering rules live there) |

## Install

Not an installable library: clone it and run the scripts in place.
```bash
git clone https://github.com/thdhyan/k1-ops
```

## Layout

```
docker/  (5 files)
  Dockerfile
  README.md
  apptainer/  (1 files)
  entrypoint.sh
  run.sh
pyproject.toml
scripts/  (62 files)
  README.md
  chain_p4_p2_host.sh
  chain_train.sh
  diag_frozen.sh
  dl_ab_push_frict_host.sh
  dl_ab_push_stiff_host.sh
  dl_ab_push_wiring_host.sh
  dl_eval_skills.sh
  dl_k1_teleop_up.sh
  dl_push_base_resume_host.sh
  dl_push_chain2_host.sh
  dl_push_chain3_host.sh
  dl_push_chain_host.sh
  dl_push_host.sh
  dl_record_push_host.sh
  dl_skills_v2.sh
  docker_isaac_fleet.sh
  install_phase6_env.sh
  k1_launch_hrl.sh
  k1_train_status.sh
  launch_dl_batch.sh
  phase6_env.sh
  probe_rewards_host.sh
  push_base_chain_host.sh
  push_ik_fetch_upload.sh
  py_torch.sh
  record_p2_final_host.sh
  record_p2_one_host.sh
  record_policies_host.sh
  setup_remote.sh
  spark_force_host.sh
  spark_full_host.sh
  spark_p2_dispcheck_host.sh
  spark_p2_gait_host.sh
  spark_p2_gaitfix_host.sh
  spark_p2_velcurriculum_host.sh
  spark_p2_velresume_host.sh
  spark_partial_host.sh
  spark_probe.sh
  spark_probe2.sh
  spark_probe3.sh
  spark_push_base_host.sh
  spark_push_host.sh
  spark_s0_container.sh
  spark_s0_host.sh
  spark_s1_host.sh
  spark_s2_host.sh
  spark_soccer_host.sh
  spark_sync_loop.sh
  start_training.sh
  sweep_standing_host.sh
  tmux_train.sh
  track_a_recovery_host.sh
  train_guard.sh
  wait_skills.sh
  wait_v10_v4.sh
  zzbw_kick_ma_v1.sh
  zzbw_kick_ma_v2.sh
  zzbw_kick_ma_v3.sh
  zzbw_kick_strike_v1.sh
  zzbw_push_chain_host.sh
  zzbw_push_smoke.sh
```

## Dependencies

- Declared sibling libraries: none (see `pyproject.toml`, `[tool.uv.sources]`).
- PyPI: none detected.
- Provided by the environment (ROS 2, Isaac, mjlab, robot SDK) or unresolved: none.

## Hard-coded paths into other repos

These files still name paths that now live in another repo (hard-coded path strings, not imports). Pass them as arguments / config when you touch the file:

| File | Refers to | Owner |
|---|---|---|
| `.github/workflows/train_smoke.yml` | `isaac_tasks/` | k1-rl-isaac |
| `docker/README.md` | `isaac_tasks/` | k1-rl-isaac |
| `docker/apptainer/zzbw_run_k1_train.sh` | `isaac_tasks/` | k1-rl-isaac |
| `docker/entrypoint.sh` | `isaac_tasks/` | k1-rl-isaac |
| `scripts/dl_k1_teleop_up.sh` | `k1_teleop/` | k1-teleop |
| `scripts/phase6_env.sh` | `isaac_tasks/` | k1-rl-isaac |
| `scripts/push_ik_fetch_upload.sh` | `mjlab_k1/` | k1-rl-mj |
| `scripts/record_p2_final_host.sh` | `isaac_tasks/` | k1-rl-isaac |
| `scripts/record_p2_one_host.sh` | `isaac_tasks/` | k1-rl-isaac |
| `scripts/start_training.sh` | `isaac_tasks/` | k1-rl-isaac |
| `scripts/zzbw_push_chain_host.sh` | `isaac_tasks/` | k1-rl-isaac |

## Origin

Extracted from `booster_ws` (branch `dev/push-training-wip`, working tree of 2026-11-03) by
`tools/build_workspace.py` in k1-workspace. Old path to new path for every file: [`docs/migration_map.tsv`](https://github.com/thdhyan/k1-workspace/blob/main/docs/migration_map.tsv) (filter on `k1-ops`).
History was not carried over: the working tree was copied as is, including previously untracked files.
