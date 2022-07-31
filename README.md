
# [GPGPU-SIM 使用篇](https://github.com/gty111/SimpleUseGpgpuSim)

## 什么是GPGPU-SIM

- 简单地说，GPGPU-SIM是一款仿真器，可以在CPU上仿真执行[CUDA](https://docs.nvidia.cn/cuda/)程序
- [主页](http://www.gpgpu-sim.org/)
- [使用手册](http://gpgpu-sim.org/manual/index.php/Main_Page)
- [github](https://github.com/gpgpu-sim/)

## 如何优雅地安装GPGPU-SIM

> **依赖=>[Spack](https://spack.readthedocs.io/en/latest/)**

- GPGPU-SIM的手动安装过程较为复杂，很容易因为依赖导致安装失败
- **强烈推荐[通过Spack安装](https://github.com/wu-kan/wu-kan.github.io/blob/a94869ef1f1f6bf5daf9535cacbfc69912c2322b/_posts/2022-01-27-%E6%A8%A1%E6%8B%9F%E5%99%A8%20GPGPU-Sim%20%E7%9A%84%E4%BD%BF%E7%94%A8%E4%BB%8B%E7%BB%8D.md)**

## 如何优雅地使用GPGPU-SIM

> **依赖=>通过spack安装GPGPU-SIM**

GPGPU-SIM仿真需要在运行目录下存在config文件，且每次运行过后都会有很多其他文件生成，导致文件混乱

### 单次仿真

- 为了解决上述问题，我写了几个脚本来在GPGPU-SIM上仿真程序

- 例如，你想使用```RTX2060```配置仿真，你的仿真程序为```test.cu```，你的Spack上CUDA版本为```11.7```，你需要通过nvcc编译仿真程序，你的Spack上GPGPU-SIM为```gpgpu-sim@4.0.1```，那么你需要在run.sh中修改变量```NAME=test```、```CONFIG=RTX2060```、```GPGPUSIM=gpgpu-sim@4.0.1```、```IFBUILD=1```，```CUDAVERSION=11.7```，将```test.cu```放到```${SRC}```目录下，并在终端中输入如下命令

  > 或者你也可以将编译好的程序放到```${BIN}```目录下，并修改```IFBUILD=0```

  ```shell
  # pwd 
  # **/SimpleUseGpgpuSim  确保当前目录在SimpleUseGpgpuSim
  . run.sh
  ```

- 此时文件(your_dir)目录结构为

  - bin 目录存放编译好或提前放置的可执行程序 
  - sim 目录存放每次仿真后GPGPU-SIM自动输出的文件和指定的配置文件
  - out 目录存放每次仿真后GPGPU-SIM的输出信息

  ```
  |-- run.sh
  |-- src
  	|-- test.cu
  |-- bin
  	|-- test
  |-- sim
  	|-- test_RTX2060_gpgpu-sim@4.0.1
  		|-- ...
  |-- out
  	|-- test_RTX2060_gpgpu-sim@4.0.1.txt
  ```

- 变量的使用详见```run.sh```中的注释

- [run.sh](https://github.com/gty111/SimpleUseGpgpuSim/blob/master/run.sh)


### 批量仿真

- 批量仿真基于单次仿真

- 假如你想仿真```test1.cu```和```test2.cu```程序，并希望使用GPGPU-SIM```4.0.1```版本仿真（需要Spack中存在以上版本），仿真配置为```RTX2060```或```QV100```，修改好的变量见```batch_run.sh```，并在终端输入如下命令

  ```shell
  # pwd 
  # **/SimpleUseGpgpuSim  确保当前目录在SimpleUseGpgpuSim
  . batch_run.sh
  ```

- 得到的文件目录结构和单次仿真一致

- [batch_run.sh](https://github.com/gty111/SimpleUseGpgpuSim/blob/master/batch_run.sh)

- [run_each.sh](https://github.com/gty111/SimpleUseGpgpuSim/blob/master/syn_gpgpu_sim.sh)

## 如何优雅地构建GPGPU-SIM
> **依赖=>通过spack安装GPGPU-SIM**

例如，你修改了GPGPU-SIM的源码，那么怎么通过Spack重新构建GPGPU-SIM？
- 可以通过```syn_gpgpu_sim.sh```完成**一键重新构建**
- 例如，你修改的GPGPU-SIM的路径为```~/gpgpu-sim```，在```syn_gpgpu_sim.sh```修改```GPGPUSIM_DIR=~/gpgpu-sim```，并在终端输入
	```shell
	 # pwd
	 # **/SimpleUseGpgpuSim  确保当前目录在SimpleUseGpgpuSim
	 . syn_gpgpu_sim.sh
	```
  > 注意需要运行命令 ```spack edit gpgpu-sim```并修改为[package.py](https://github.com/gty111/SimpleUseGpgpuSim/blob/master/package.py)
- 变量的使用详见```syn_gpgpu_sim.sh```中的注释
- [syn_gpgpu_sim.sh](https://github.com/gty111/SimpleUseGpgpuSim/blob/master/syn_gpgpu_sim.sh)
