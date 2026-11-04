# =============================================================================
# STAGE 2 — thin runtime image on top of the pushed stage-1 base.
#
# The base (docker/Dockerfile.base) carries Isaac Lab + pinned deps + the
# entrypoint. This stage exists ONLY to retag a personal base for sharing.
# Workspace source is cloned at RUNTIME — never baked — so one image serves
# any branch/commit.
#
# Build (after `docker build -f docker/Dockerfile.base ...` + push):
#   docker build -f docker/Dockerfile \
#     --build-arg BASE_IMAGE=docker.io/<dockerhub-user>/k1-isaac-base:3.0.0b2 \
#     -t <dockerhub-user>/k1-isaac-train:3.0.0b2 .
#
# No-Docker-Hub workflow: skip this file — run/push Dockerfile.base directly.
# =============================================================================
ARG BASE_IMAGE=docker.io/thdhyan/k1-isaac-base:3.0.0b2
FROM ${BASE_IMAGE}

USER root

# Runtime defaults (override with docker run -e ...). Repo, branch, workdir and
# train script default per K1_LAYOUT inside the entrypoint; K1_LAYOUT=legacy
# runs the old booster_ws repo.
ENV K1_LAYOUT=workspace \
    K1_MOUNT_DIR=/workspace/mounts

WORKDIR /workspace

# entrypoint already present in the base; re-COPY for standalone edits
COPY docker/entrypoint.sh /usr/local/bin/k1-entrypoint.sh
RUN chmod +x /usr/local/bin/k1-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/k1-entrypoint.sh"]
# Default: stage-1 teacher training (override via `docker run ... <args>`)
CMD ["--task", "Isaac-Velocity-Rough-K1-Teacher-v0", "--num_envs", "4096", "--headless"]
