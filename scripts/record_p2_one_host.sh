#!/bin/bash
# Record + verify + upload ONE P2 policy (teacher, while the student trains).
# Same discipline as record_p2_final_container.sh: panel viz, finite-trace gate,
# >0.5 m displacement gate, poster, TorchScript export, Drive upload.
#
#   P2_REC_CKPT=<path> P2_REC_TASK=<gym id> P2_REC_NAME=<basename> \
#   bash scripts/record_p2_one_host.sh
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$HOME/Projects/booster_ws"
: "${P2_REC_CKPT:?P2_REC_CKPT required}"
: "${P2_REC_TASK:?P2_REC_TASK required}"
: "${P2_REC_NAME:?P2_REC_NAME required}"
LOG="$HERE/p2_rec_one.log"
CACHE="$HERE/k1_isaac_cache_p2_rec_one"
mkdir -p "$CACHE"
: > "$LOG"

docker run --rm --gpus all --user 0 --entrypoint bash \
  -e ACCEPT_EULA=Y -e OMNI_KIT_ALLOW_ROOT=1 -e TERM=xterm \
  -e NVIDIA_DRIVER_CAPABILITIES=all -e K1_PHYSICS=physx \
  -e P2_REC_CKPT="$P2_REC_CKPT" -e P2_REC_TASK="$P2_REC_TASK" \
  -e P2_REC_NAME="$P2_REC_NAME" \
  -v "$HERE/record_p2_one_container.sh:/rec.sh:ro" \
  -v "$CACHE:/root/.cache" -v "$REPO:/workspace/booster_ws" \
  nvcr.io/nvidia/isaac-lab:3.0.0-beta2-post1 /rec.sh > "$LOG" 2>&1 || {
    echo "P2_REC_ONE_DOCKER=FAIL"; tail -20 "$LOG"; exit 1; }

grep -E "P2_REC_MOVE|P2_REC_ONE_DONE|P2_REC_UPLOAD|Traceback" "$LOG" || true
export PATH="$HOME/.local/bin:$PATH"
OUT="$REPO/isaac_tasks/k1_velocity/videos"
for f in "$P2_REC_NAME.mp4" "${P2_REC_NAME}_poster.png"; do
  rclone copyto "$OUT/$f" "gdrive-thakk100:K1 Policy Play Videos — booster_ws/Track A Interim/$f" --log-level INFO
done
rclone copyto "$REPO/models/${P2_REC_NAME}.pt" \
  "gdrive-thakk100:K1 Policy Play Videos — booster_ws/Track A Interim/${P2_REC_NAME}.pt" --log-level INFO
echo "P2_REC_UPLOAD_MARKER=OK"
echo "log: $LOG"
