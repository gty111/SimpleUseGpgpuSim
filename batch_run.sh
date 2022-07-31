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

if [ ! ${#NAME_ARR[@]} -eq ${#ARG_ARR[@]} ] ; then
  	echo "length of NAME and ARG not equal"
elif [ ! -e ${RUNEACH} ] ; then
	echo ${RUNEACH} "not exist"
elif [ ${#GPGPUSIM_ARR[@]} -eq 0 ] ; then 
	echo "please set GPGPUSIM_ARR"
elif [ ${#CONFIG_ARR[@]} -eq 0 ] ; then
	echo "please set CONFIG_ARR"
else
  for ((i=0;i<${#NAME_ARR[@]};i++)) ; do
	for ((j=0;j<${#GPGPUSIM_ARR[@]};j++)) ; do
		for ((k=0;k<${#CONFIG_ARR[@]};k++)) ; do
			echo "--------------"
			export  NAME=${NAME_ARR[${i}]}
			export  ARG=${ARG_ARR[${i}]}
			export  GPGPUSIM=${GPGPUSIM_ARR[${j}]}
			export  CONFIG=${CONFIG_ARR[${k}]}
			. ${RUNEACH}
		done
	done
  done
fi