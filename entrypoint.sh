#!/bin/bash --login

spack env activate -d ${CHFS_SPACK_ENV}

if [ ! $# -eq 0 ]; then
    exec "$@"
fi
