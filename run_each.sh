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
# CONFIG_SELECT : 0 only build sim env 1 run 2 run rebuild env

OUTPATH=${CURDIR}/${OUT}/${OUTNAME}_${CONFIG}_${GPGPUSIM}.txt
SIMPATH=${CURDIR}/${SIM}/${OUTNAME}_${CONFIG}_${GPGPUSIM}
EXEPATH=${CURDIR}/${BIN}/${NAME}

if [ ! -d ${SIMPATH} ] && [ ${CONFIG_SELECT} -eq 1 ]
then # test SIMPATH exists
	echo "build sim env first"
else
	if [ ${CONFIG_SELECT} -ne 1 ]
	then
		echo "build sim env"
		rm -rf ${SIMPATH}
		cp -r $(spack location -i \
			${GPGPUSIM})/gpgpu-sim_distribution/configs/tested-cfgs/SM*_${CONFIG} ${SIMPATH}
	else
		echo "use existed sim env"
	fi

	export CUDA_INSTALL_PATH=$(spack location -i cuda@${CUDAVERSION})
	. $(spack location -i ${GPGPUSIM})/gpgpu-sim_distribution/setup_environment 2>&1 1>&/dev/null
	
	if [ ${CONFIG_SELECT} -ne 0 ]
	then
		echo "execute" ${NAME} ${ARG} "on" ${GPGPUSIM} ${CONFIG}
	fi

	if [ ${IFBACKGROUND} -eq 1 ] && [ ${CONFIG_SELECT} -ne 0 ]
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

