FROM buildpack-deps:buster

ARG USERNAME=chfs
ARG USER_UID=1000
ARG USER_GID=$USER_UID

ENV SPACK_ROOT=/home/${USERNAME}/.cache/spack

SHELL ["/bin/bash", "-c"]

RUN \
  # Create a non-root user
  groupadd --gid $USER_GID $USERNAME \
  && useradd \
    -s /bin/bash \
    --uid $USER_UID \
    --gid $USER_GID \
    -m $USERNAME \
  # Common packages
  && export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get -y install --no-install-recommends \
    git \
    locales \
    python3 \
  # Ensure at least the en_US.UTF-8 UTF-8 locale is available.
  && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
  && locale-gen \
  # Clean up
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8

COPY etc/profile.d/03-spack.sh /etc/profile.d/03-spack.sh

USER ${USERNAME}
RUN \
  # spack
  git clone -c feature.manyFiles=true https://github.com/spack/spack.git "${SPACK_ROOT}" \
  && mkdir -p /home/${USERNAME}/.spack

USER root
RUN \
  # Common packages
  export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get -y install --no-install-recommends \
    cmake \
    pkg-config \
    rdma-core \
    fuse \
    libfuse-dev \
  # Clean up
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*

ARG SPACK_EXTENSION=/home/${USERNAME}/.spack-extension
ARG CHFS_SRC_SPACK_ENV=chfs
ENV CHFS_SPACK_ENV=${SPACK_EXTENSION}/envs/${CHFS_SRC_SPACK_ENV}

USER ${USERNAME}
SHELL ["/bin/bash", "-l", "-c"]
COPY --chown=${USERNAME}:${USERNAME} \
  spack/repos/chfs-spack-packages/ \
  ${SPACK_EXTENSION}/repos/chfs-spack-packages
COPY --chown=${USERNAME}:${USERNAME} \
  spack/repos/mochi-spack-packages/ \
  ${SPACK_EXTENSION}/repos/mochi-spack-packages
COPY --chown=${USERNAME}:${USERNAME} \
  spack/envs/${CHFS_SRC_SPACK_ENV}/spack.yaml \
  ${CHFS_SPACK_ENV}/
COPY --chown=${USERNAME}:${USERNAME} \
  spack/envs/${CHFS_SRC_SPACK_ENV}/spack.lock \
  ${CHFS_SPACK_ENV}/
RUN \
  spack env activate ${CHFS_SPACK_ENV} \
  && spack install

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
