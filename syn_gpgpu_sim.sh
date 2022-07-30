# install your modified GPGPUSIM from your local dir on spack
# GPGPUSIM : name of GPGPU-Sim on spack (include version)
# GPGPUSIM_DIR : source of GPGPUSIM to install (modify or not)
# MIRROR_DIR : dir of spack manual mirror (recommend ~/.spack/manual_mirror)
# MIRROR_NAME : name of spack mirror

GPGPUSIM=gpgpu-sim-modify@dev
GPGPUSIM_DIR=~/gpgpu-sim
MIRROR_DIR=~/.spack/manual_mirror
MIRROR_NAME=gty

GPGPUSIM_MIRROR_DIR=${MIRROR_DIR}/$(echo ${GPGPUSIM} | sed 's/@.*//')
GPGPUSIM_TARBALL=${GPGPUSIM_MIRROR_DIR}/$(echo ${GPGPUSIM} | sed 's/@/-/').tar.gz
CUR_DIR=$(pwd)

if spack -V > /dev/null ; [ $? -ne 0 ]
then
    echo "fail to find spack"
elif [ ! -d ${GPGPUSIM_DIR} ]
then
    echo "GPGPUSIM_DIR" ${GPGPUSIM_DIR} "not exists"
else 
    [ ! -d ${MIRROR_DIR} ] && mkdir ${MIRROR_DIR}
    [ ! -d ${GPGPUSIM_MIRROR_DIR} ] && mkdir ${GPGPUSIM_MIRROR_DIR}
    spack mirror add ${MIRROR_NAME} ${MIRROR_DIR} 2>&1 1>&/dev/null
    cd ${GPGPUSIM_DIR} && tar -czf ${GPGPUSIM_TARBALL} * 
    spack uninstall -y ${GPGPUSIM}
    spack install ${GPGPUSIM}
    cd ${CUR_DIR}
fi

