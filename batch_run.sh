NAME_ARR=("test1" "test2")
ARG_ARR=("" "")
GPGPUSIM_ARR=("gpgpu-sim@4.0.1" ) 
CONFIG_ARR=("RTX2060" "QV100")
RUNEACH=run_each.sh

export CUDAVERSION=11.7
export ARCH=sm_70
export IFBUILD=1
export IFBACKGROUND=0
export CONFIG_SELECT=2
export BIN=bin
export OUT=out
export SRC=src
export SIM=sim
export CURDIR=$(pwd)

[ ! -d ${SRC} ] && mkdir ${SRC}
[ ! -d ${SIM} ] && mkdir ${SIM}
[ ! -d ${BIN} ] && mkdir ${BIN}
[ ! -d ${OUT} ] && mkdir ${OUT}

if spack load cuda@${CUDAVERSION} > /dev/null ; [ $? -ne 0 ] ; then # test load cuda
	echo "fail to load cuda@"${CUDAVERSION}
elif spack -V > /dev/null ; [ $? -ne 0 ]
then
	echo "fail to find spack"
elif [ ! ${#NAME_ARR[@]} -eq ${#ARG_ARR[@]} ] ; then
  	echo "length of NAME and ARG not equal"
elif [ ! -e ${RUNEACH} ] ; then
	echo ${RUNEACH} "not exist"
elif [ ${#GPGPUSIM_ARR[@]} -eq 0 ] ; then 
	echo "please set GPGPUSIM_ARR"
elif [ ${#CONFIG_ARR[@]} -eq 0 ] ; then
	echo "please set CONFIG_ARR"
else
  # check GPGPU-SIM
  for ((i=0;i<${#GPGPUSIM_ARR[@]};i++)) ; do
	GPGPUSIM=${GPGPUSIM_ARR[${j}]}
	if spack location -i ${GPGPUSIM} > /dev/null ; [ $? -ne 0 ] 
	then # test GPGPUSIM exist 
		echo ${GPGPUSIM} "not found"
		exit
	fi
  done

  # check config exist
  for ((i=0;i<${#CONFIG_ARR[@]};i++)) ; do
	CONFIG=${CONFIG_ARR[${i}]}
	for ((j=0;j<${#GPGPUSIM_ARR[@]};j++)) ; do
		GPGPUSIM=${GPGPUSIM_ARR[${j}]}
		if [ ! -d $(spack location -i ${GPGPUSIM})/gpgpu-sim_distribution/configs/tested-cfgs/SM*_${CONFIG} ]
		then # test config exists
			echo "config" ${CONFIG} "not exists in" ${GPGPUSIM}
			ls $(spack location -i ${GPGPUSIM})/gpgpu-sim_distribution/configs/tested-cfgs
			exit
		fi
	done
  done 

  # check src or bin
  for ((i=0;i<${#NAME_ARR[@]};i++)) ; do
	NAME=${NAME_ARR[${i}]}
	if [ ! -e ${SRC}/${NAME}.cu ] && [ ${IFBUILD} -eq 1 ]  # test *.cu exist
	then
		echo ${SRC}/${NAME}.cu "not exists"
		exit
	elif [ ! -e ${BIN}/${NAME} ] && [ ${IFBUILD} -eq 0 ] # test binary exist
	then
		echo ${BIN}/${NAME} "not exists"
		exit
	fi
  done

  # build single *.cu
  if [ ${IFBUILD} -eq 1 ] ; then
	for ((i=0;i<${#NAME_ARR[@]};i++)) ; do
	  NAME=${NAME_ARR[${i}]}
	  echo "build" ${NAME}.cu
	  nvcc -arch=${ARCH} --cudart shared ${SRC}/${NAME}.cu -o ${BIN}/${NAME} 
	  if [ ! $? -eq 0 ] ; then 
		echo "fail to build" ${NAME}
		exit
	  fi
	done
  fi


  for ((i=0;i<${#CONFIG_ARR[@]};i++)) ; do
	for ((j=0;j<${#GPGPUSIM_ARR[@]};j++)) ; do
		for ((k=0;k<${#NAME_ARR[@]};k++)) ; do
			echo "--------------"
			export  CONFIG=${CONFIG_ARR[${i}]}
			export  GPGPUSIM=${GPGPUSIM_ARR[${j}]}
			export  NAME=${NAME_ARR[${k}]}
			export  OUTNAME=${NAME}
			export  ARG=${ARG_ARR[${k}]}
			. ${RUNEACH}
		done
	done
  done
fi