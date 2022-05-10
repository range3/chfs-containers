#!/bin/bash --login

spack env activate -d ${CHFS_SPACK_ENV}
export PATH="${CHFS_SPACK_ENV}/.spack-env/view/sbin:$PATH"

if [ ! $# -eq 0 ]; then
    exec "$@"
fi
