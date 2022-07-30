# build single *.cu program or run bin/${NAME} on GPGPU-Sim at specified config under spack env
# GPGPUSIM : name of GPGPU-Sim on spack
# CONFIG : which config on GPGPU-Sim eg. RTX2060 GTX480 TITANV
# NAME : ${SRC}/${NAME}.cu or ${BIN}/${NAME}
# OUTNAME : part name of GPGPU-Sim generated file 
# BIN : dir where binary file lie
# OUT : dir where generated file lie
# SRC : dir where source file lie
# SIM : dir where execute simulating
# IFBUILD : 1 not skip build ; 0 skip build and just use bin/${NAME}
# IFBACKGROUND : 1 background ; 0 foreground
# ARG : arg pass to the program
# ARCH : nvcc -arch=${ARCH} use for build 
# IFDEBUG : 1 use gdb and source debug in GPGPUSIM; 0 not use gdb
# CONFIG_SELECT : 0 only build sim env 1 run 2 run rebuild env

NAME=test1
CONFIG=RTX2060 # ${CONFIG}=help (to see what config gpgpusim has)
GPGPUSIM=gpgpu-sim@4.0.1
CUDAVERSION=11.7
ARCH=sm_70
IFBUILD=1
IFBACKGROUND=0
IFDEBUG=0
CONFIG_SELECT=2 # 0 only build sim env ;1 run ;2 run rebuild env
ARG=

OUTNAME=${NAME}

BIN=bin
OUT=out
SRC=src
SIM=sim

CURDIR=$(pwd)

OUTPATH=${CURDIR}/${OUT}/${OUTNAME}_${CONFIG}_${GPGPUSIM}.txt
SIMPATH=${CURDIR}/${SIM}/${OUTNAME}_${CONFIG}_${GPGPUSIM}
EXEPATH=${CURDIR}/${BIN}/${NAME}

[ ! -d ${SRC} ] && mkdir ${SRC}

if spack -V > /dev/null ; [ $? -ne 0 ]
then
	echo "fail to find spack"
elif spack load cuda@${CUDAVERSION} > /dev/null ; [ $? -ne 0 ] 
then # test load cuda
	echo "fail to load cuda@"${CUDAVERSION}
elif spack location -i ${GPGPUSIM} > /dev/null ; [ $? -ne 0 ] 
then # test GPGPUSIM exist 
	echo ${GPGPUSIM} "not found"
elif [ ! -e ${SRC}/${NAME}.cu ] && [ ${IFBUILD} -eq 1 ]  # test *.cu exist
then
	echo ${SRC}/${NAME}.cu "not exists"
elif [ ! -e ${BIN}/${NAME} ] && [ ${IFBUILD} -eq 0 ] # test binary exist
then
	echo ${BIN}/${NAME} "not exists"
elif [ ! -d $(spack location -i ${GPGPUSIM})/gpgpu-sim_distribution/configs/tested-cfgs/SM*_${CONFIG} ]
then # test config exists
	echo "config" ${CONFIG} "not exists"
	ls $(spack location -i ${GPGPUSIM})/gpgpu-sim_distribution/configs/tested-cfgs
elif [ ! -d ${SIMPATH} ] && [ ${CONFIG_SELECT} -eq 1 ]
then # test SIMPATH exists
	echo "build sim env first"
else
	#init dir
	[ ! -d ${SIM} ] && mkdir ${SIM}
	[ ! -d ${BIN} ] && mkdir ${BIN}
	[ ! -d ${OUT} ] && mkdir ${OUT}

	if [ ${CONFIG_SELECT} -ne 1 ]
	then
		echo "build sim env"
		rm -rf ${SIMPATH}
		cp -r $(spack location -i \
			${GPGPUSIM})/gpgpu-sim_distribution/configs/tested-cfgs/SM*_${CONFIG} ${SIMPATH}
	else
		echo "use existed sim env"
	fi

	if [ ${IFBUILD} -eq 1 ] 
	then
		echo "build" ${NAME}.cu
		nvcc -arch=${ARCH} --cudart shared ${SRC}/${NAME}.cu -o ${BIN}/${NAME} 
	else 
		echo "skip build"
	fi

	export CUDA_INSTALL_PATH=$(spack location -i cuda@${CUDAVERSION})
	if [ ${IFDEBUG} -eq 0 ]; then
		. $(spack location -i ${GPGPUSIM})/gpgpu-sim_distribution/setup_environment 2>&1 1>&/dev/null
	else
		. $(spack location -i ${GPGPUSIM})/gpgpu-sim_distribution/setup_environment debug 2>&1 1>&/dev/null
	fi 

	if [ ${CONFIG_SELECT} -ne 0 ]
	then
		echo "execute" ${NAME} ${ARG} "on" ${GPGPUSIM} ${CONFIG}
	fi

	if [ ${IFDEBUG} -eq 1 ] && [ ${CONFIG_SELECT} -ne 0 ]
	then
		cd ${SIMPATH} && gdb ${EXEPATH} 
	elif [ ${IFBACKGROUND} -eq 1 ] && [ ${CONFIG_SELECT} -ne 0 ]
	then
		cd ${SIMPATH} && \
		nohup ${EXEPATH} ${ARG} > ${OUTPATH} 2>&1 & # run at background
	elif [ ${CONFIG_SELECT} -ne 0 ]
	then
		cd ${SIMPATH} && \
		${EXEPATH} ${ARG} > ${OUTPATH} # run at foreground
	fi
	cd ${CURDIR}
fi

