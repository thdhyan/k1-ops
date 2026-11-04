#!/usr/bin/env bash
# remote_train.sh: run an mjlab (k1-rl-mj) training on any SSH-reachable CUDA host.
#
#   K1_HOSTS="csel-cuda-01.cselabs.umn.edu csel-cuda-03.cselabs.umn.edu" remote_train.sh <command>
#
#   pick                                  first host with an idle GPU: prints "<host> <gpu>"
#   up <task> [--host H] [--gpu N] [--name NAME] [-- extra k1-train args]
#   status [NAME]                         no NAME: list runs. With NAME: state, last log lines, GPU
#   fetch NAME [DEST]                     copy checkpoints + log (default $K1_MODELS_DIR/mjlab_k1/NAME)
#   stop NAME                             kill the run's tmux session
#
# Hosts come from $K1_HOSTS (ssh aliases or names); nothing is hard-coded. Hosts that do not answer a key login
# within 10 s are skipped. Needs on the host: python3 (>=3.10), tmux, an NVIDIA driver, outbound pip access.
# Env: K1_WORKSPACE (k1-workspace checkout, default: the one this script is in), K1_REMOTE_DIR (relative to the
# remote $HOME, default k1_run), K1_MAX_GPU_MEM_MB (a GPU is idle below this, default 1000), K1_NUM_ENVS
# (default 1024, sized for a 16 GB T4), K1_RUNS_FILE (default ~/.k1_remote_runs), K1_DRY_RUN=1 (print, do not run).
set -euo pipefail

WS=${K1_WORKSPACE:-$(cd "$(dirname "$0")/../../.." && pwd)}
RD=${K1_REMOTE_DIR:-k1_run}
MAXMEM=${K1_MAX_GPU_MEM_MB:-1000}
NENVS=${K1_NUM_ENVS:-1024}
RUNS=${K1_RUNS_FILE:-$HOME/.k1_remote_runs}
LIBS=(k1-common k1-description k1-utils k1-runtime k1-rl-mj)

die() { echo "remote_train: $*" >&2; exit 1; }
dry() { [ -n "${K1_DRY_RUN:-}" ]; }
sshr() { local h=$1; shift; if dry; then echo "[ssh $h] $*" >&2; else ssh -o BatchMode=yes -o ConnectTimeout=10 "$h" "$@"; fi; }
host_of() { awk -v n="$1" '$1 == n {print $2, $3}' "$RUNS" 2>/dev/null | tail -1; }

pick() {
  [ -n "${K1_HOSTS:-}" ] || die "set K1_HOSTS to a space-separated list of hosts"
  local h out
  for h in $K1_HOSTS; do
    if dry; then echo "$h 0"; return; fi
    if ! out=$(ssh -o BatchMode=yes -o ConnectTimeout=10 "$h" \
        'nvidia-smi --query-gpu=index,memory.used --format=csv,noheader,nounits' 2>/dev/null); then
      echo "skip $h: no key login or no nvidia-smi" >&2; continue
    fi
    echo "$out" | awk -F', *' -v h="$h" -v m="$MAXMEM" '$2 < m {print h, $1; found=1; exit} END {exit !found}' && return
    echo "skip $h: GPUs busy" >&2
  done
  die "no idle GPU on: $K1_HOSTS"
}

# third-party requirements of the five libraries (sibling k1-* libs come from PYTHONPATH instead)
deps() {
  python3 - "$WS" "${LIBS[@]}" <<'EOF'
import sys, tomllib
ws, libs = sys.argv[1], sys.argv[2:]
SKIP = {"evdev", "pytest"}  # pad driver (needs a C build) and test runner: not needed to train
out = set()
for lib in libs:
    with open(f"{ws}/libs/{lib}/pyproject.toml", "rb") as f:
        out |= {d for d in tomllib.load(f)["project"].get("dependencies", []) if not d.startswith("k1-") and d.split("[")[0] not in SKIP}
print(" ".join(sorted(out)))
EOF
}

up() {
  [ $# -ge 1 ] || die "usage: up <task> [--host H] [--gpu N] [--name NAME] [-- extra args]"
  local task=$1 host="" gpu="" name=""; shift
  while [ $# -gt 0 ]; do
    case $1 in
      --host) host=$2; shift 2;; --gpu) gpu=$2; shift 2;; --name) name=$2; shift 2;;
      --) shift; break;; *) die "unknown option $1";;
    esac
  done
  for l in "${LIBS[@]}"; do [ -d "$WS/libs/$l/src" ] || die "$WS/libs/$l/src missing: set K1_WORKSPACE"; done
  [ -n "$name" ] || name=$(echo "${task}" | tr 'A-Z' 'a-z' | tr -c 'a-z0-9\n' '-' | sed 's/-*$//')-$(date +%m%d-%H%M)
  if [ -z "$host" ]; then read -r host gpu < <(pick); else gpu=${gpu:-0}; fi
  local d=$RD/$name v=$RD/venv req md5
  req=$(deps); md5=$(echo "$req" | md5sum | cut -c1-12)
  echo "run $name on $host GPU $gpu"

  sshr "$host" 'command -v tmux >/dev/null && command -v python3 >/dev/null' || die "$host needs tmux and python3"
  sshr "$host" "mkdir -p $d/src"
  dry && echo "[rsync] ${LIBS[*]} -> $host:$d/src/" || \
    (cd "$WS/libs" && rsync -a --exclude=.git --exclude=__pycache__ --exclude='*.pt' --exclude=tests "${LIBS[@]}" "$host:$d/src/")

  # shared venv with third-party deps only; reinstalled when the requirement set changes
  sshr "$host" "set -e; if [ \"\$(cat $v/.deps 2>/dev/null)\" != $md5 ]; then
      if command -v uv >/dev/null; then uv venv -q --python python3 $v && uv pip install -q --python $v/bin/python $req;
      else python3 -m venv $v && $v/bin/pip install -q -U pip && $v/bin/pip install -q $req; fi
      echo $md5 > $v/.deps; fi"

  local pp="" l; for l in "${LIBS[@]}"; do pp+="\$HOME/$d/src/$l/src:"; done
  local script="#!/bin/bash
cd \"\$HOME/$d\"
export CUDA_VISIBLE_DEVICES=$gpu WANDB_MODE=disabled MUJOCO_GL=egl PYTHONPATH=\"${pp%:}\"
\"\$HOME/$v/bin/python\" -c 'from mjlab_k1.cli import train; train()' $task --env.scene.num-envs $NENVS \\
  --agent.run-name $name --agent.logger tensorboard $* > train.log 2>&1
echo \"EXIT \$?\" >> train.log"
  if dry; then echo "[run.sh]"; echo "$script"; else echo "$script" | ssh -o BatchMode=yes "$host" "cat > $d/run.sh"; fi
  sshr "$host" "tmux new -d -s k1-$name 'bash \$HOME/$d/run.sh'"
  dry || echo "$name $host $gpu" >> "$RUNS"
  echo "started. watch: $0 status $name"
}

status() {
  if [ $# -eq 0 ]; then cat "$RUNS" 2>/dev/null || echo "no runs recorded in $RUNS"; return; fi
  local hg host gpu; hg=$(host_of "$1"); [ -n "$hg" ] || die "unknown run $1 (see: status)"
  read -r host gpu <<<"$hg"
  sshr "$host" "tmux has-session -t k1-$1 2>/dev/null && echo RUNNING || echo FINISHED/STOPPED;
    tail -n 5 $RD/$1/train.log; nvidia-smi --query-gpu=index,memory.used,utilization.gpu --format=csv,noheader"
}

fetch() {
  local hg host gpu; hg=$(host_of "${1:?usage: fetch NAME [DEST]}"); [ -n "$hg" ] || die "unknown run $1"
  read -r host gpu <<<"$hg"
  local dest=${2:-${K1_MODELS_DIR:-$HOME/k1_models}/mjlab_k1/$1}
  mkdir -p "$dest"
  if dry; then echo "[rsync] $host:$RD/$1/ -> $dest"; return; fi
  rsync -a --include='*/' --include='model_*.pt' --include='events.out*' --include='train.log' --exclude='*' \
    "$host:$RD/$1/" "$dest/"
  echo "fetched to $dest"
}

stop() {
  local hg host gpu; hg=$(host_of "${1:?usage: stop NAME}"); [ -n "$hg" ] || die "unknown run $1"
  read -r host gpu <<<"$hg"
  sshr "$host" "tmux kill-session -t k1-$1" && echo "stopped $1"
}

cmd=${1:-}; [ -n "$cmd" ] && shift || true
case $cmd in
  pick) pick;; up) up "$@";; status) status "$@";; fetch) fetch "$@";; stop) stop "$@";;
  *) sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 2;;
esac
