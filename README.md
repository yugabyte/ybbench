# YB-Bench
----------------------------------------------------------
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Documentation Status](https://readthedocs.org/projects/ansicolortags/badge/?version=latest)](https://docs.yugabyte.com/)
[![Ask in forum](https://img.shields.io/badge/ask%20us-forum-orange.svg)](https://forum.yugabyte.com/)
[![Slack chat](https://img.shields.io/badge/Slack:-%23yugabyte_db-blueviolet.svg?logo=slack)](https://www.yugabyte.com/slack)
[![Analytics](https://yugabyte.appspot.com/UA-104956980-4/home?pixel&useReferer)](https://github.com/yugabyte/ga-beacon)


* [What is YBBENCH Docker Container?](#what-is-yb-benchmark-docker-container)
* [How to use](#how-to-use)
* [Build from source code](#build-from-source-code)
* [YBBENCH In Interactive Mode](#ybbench-in-interactive-mode)

## What is YB-Bench Docker Container?
This benchmark docker container is a way to easily run various benchmarks on the YugabyteDB.

This includes following benchmarks pre-installed and ready to be used:
1. [TPC-C](https://github.com/yugabyte/tpcc)
2. [SYSBENCH](https://github.com/yugabyte/sysbench)
3. [YCSB](https://github.com/yugabyte/ycsb)
4. [YB-SAMPLE-APPS](https://github.com/yugabyte/yb-sample-apps)

## How to use.
- #### Pull the docker image
   ```shell
   docker pull yugabytedb/ybbench:latest
   ```
- #### Get the benchmark help by running the container
   ```shell
    docker run --name ybbench --rm -it yugabytedb/ybbench:latest
   ```
  Above run command will print out following help
  ```shell
  ******************************************************************************
  *                                                                            *
  *                         YugabyteDB Benchmark Help                          *
  *                                                                            *
  ******************************************************************************
  *         This tool is used to run the benchmarks on YugabyteDB              *

     Syntax: ./run [tpccbenchmark/sysbench/yb-sample-apps/ycsb] [params]

      Benchmark Options:

          tpccbenchmark                 to run tpcc benchmark.
          sysbench                      to run sysbench benchmark
          yb-sample-apps                to run yb-sample-apps
          ycsb                          to run ycsb benchmark

  ******************************************************************************
  ```
- #### Get specific benchmark help(-h/--help)
   ```shell
    docker run --name ybbench --rm -it yugabytedb/ybbench:latest ./run <benchmark> --help
    # example:
    # docker run --name ybbench --rm -it yugabytedb/ybbench:latest ./run tpccbenchmark -h
   ```
  
- #### Run specific Benchmark
  - ##### Run sample tpcc workload(Provide comma separated list of nodes). More info can be found on [TPCC](https://github.com/yugabyte/tpcc) repository.
    ```shell
    # create tpcc db
    docker run --name ybbench --rm -it yugabytedb/ybbench:latest ./run tpccbenchmark --create=true --nodes=<node1-ip,node2-ip,node3-ip>
    
    # load the data
    docker run --name ybbench --rm -it yugabytedb/ybbench:latest ./run tpccbenchmark --load=true --nodes=<node1-ip,node2-ip,node3-ip> --warehouses=10 --loaderthreads=10
    
    # execute phase
    docker run --name ybbench --rm -it yugabytedb/ybbench:latest ./run tpccbenchmark --execute=true --nodes=<node1-ip,node2-ip,node3-ip> --warehouses=10 --warmup-time-secs=0    
    ```
    To modify the workload related properties in TPCC -[workload_all.xml](https://github.com/yugabyte/tpcc/blob/master/config/workload_all.xml), you can mount the file as a volume.
    ```shell
    # download the file
    wget wget https://raw.githubusercontent.com/yugabyte/tpcc/master/config/workload_all.xml
    
    # modify workload_all.xml in any editor and run the benchmark
    docker run -v $(pwd)/workload_all.xml:/home/centos/code/tpcc/config/workload_all.xml --name ybbench --rm -it \
    yugabytedb/ybbench:latest ./run tpccbenchmark \
    --create=true --nodes=<node1-ip,node2-ip,node3-ip>
    ```
    Alternatively, you can run ybbench in [interactive mode](#ybbench-in-interactive-mode).
    
  - ##### Run sample sysbench workload. More info can be found on [SYSBENCH](https://github.com/yugabyte/sysbench) repository. 
    ```shell
    # cleanup phase
    docker run --name ybbench --rm -it yugabytedb/ybbench:latest ./run sysbench oltp_insert --threads=10 --time=30 --table_size=10000 --tables=1 --warmup-time=0 --range_key_partitioning=false --range_selects=true --thread-init-timeout=30 --serial_cache_size=1000 --db-driver=pgsql --pgsql-db=yugabyte --pgsql-port=5433 --pgsql-user=yugabyte --pgsql-host=<node1-ip,node2-ip,node3-ip> cleanup
    # prepare phase
    docker run --name ybbench --rm -it yugabytedb/ybbench:latest ./run sysbench oltp_insert --threads=10 --time=30 --table_size=10000 --tables=1 --warmup-time=0 --range_key_partitioning=false --range_selects=true --thread-init-timeout=30 --serial_cache_size=1000 --db-driver=pgsql --pgsql-db=yugabyte --pgsql-port=5433 --pgsql-user=yugabyte --pgsql-host=<node1-ip,node2-ip,node3-ip> prepare
    # run phase
    docker run --name ybbench --rm -it yugabytedb/ybbench:latest ./run sysbench oltp_insert --threads=10 --time=30 --table_size=10000 --tables=1 --warmup-time=0 --range_key_partitioning=false --range_selects=true --thread-init-timeout=30 --serial_cache_size=1000 --db-driver=pgsql --pgsql-db=yugabyte --pgsql-port=5433 --pgsql-user=yugabyte --pgsql-host=<node1-ip,node2-ip,node3-ip> run
    ```
  - ##### Run ycsb workload. More info can be found on [YCSB](https://github.com/yugabyte/ycsb) repository.
    ```shell
    # load
    docker run --name ybbench --rm -it yugabytedb/ybbench:latest ./run ycsb load basic -P workloads/workloada
     
    # run
    docker run --name ybbench --rm -it yugabytedb/ybbench:latest ./run ycsb run basic -P workloads/workloada
    ```
    To modify the workload related properties in YCSB -[db.properties](https://github.com/yugabyte/YCSB/blob/master/yugabyteSQL/db.properties), you can mount the file as a volume.
    ```shell
    # download the file
    wget https://raw.githubusercontent.com/yugabyte/YCSB/master/yugabyteSQL/db.properties
     
    # modify the db.properties in any editor and run the benchmark
    docker run -v $(pwd)/db.properties:/home/centos/code/YCSB/yugabyteSQL/db.properties \
    --name ybbench --rm -it yugabytedb/ybbench:latest ./run ycsb load basic -P workloads/workloada
    ```    
  
    Alternatively, you can run ybbench in [interactive mode](#ybbench-in-interactive-mode)
  
  - ##### Run yb-sample-apps workload. More info can be found on [YB-SAMPLE-APPS](https://github.com/yugabyte/yb-sample-apps) repository.
    ```shell
    docker run --name ybbench --rm -it yugabytedb/ybbench:latest ./run yb-sample-apps --workload CassandraKeyValue --value_size 16 --num_unique_keys 1000000 --num_threads_read 0 --num_threads_write 256 --nodes <node1-ip>:9042,<node2-ip>:9042,<node3-ip>:9042 --use_ascii_values create_table_name PerfTest_0 --output_json_metrics 
    ```
## Build from source code
You can build the docker image from the specific branches of respective benchmark repositories.
1. Clone this repository
    ```shell
    git clone https://github.com/yugabyte/ybbench.git
    ```
2. change dir and run docker build
    ```shell
    cd ybbench
    # master branches is used by default if not specified
    docker build -t ybbench:0.1 .
    ```
    To build from specific branch
    ```shell
    docker build -t ybbench:0.1 --build-arg tpcc_branch=<my-branch> \
    --build-arg sysbench_branch=<my-branch> --build-arg sample_apps_branch=<my-branch> \
    --build-arg ycsb_branch=<my-branch> .
    ```

## YBBENCH in interactive mode
Before running any benchmarks you may want to modify/override certain properties files like:
1. [workload_all.xml](https://github.com/yugabyte/tpcc/blob/master/config/workload_all.xml) file in TPCC
2. YSQL [db.properties](https://github.com/yugabyte/YCSB/blob/master/yugabyteSQL/db.properties) or YCQL [db.properties](https://github.com/yugabyte/YCSB/blob/master/yugabyteCQL/db.properties) file in ycsb


To achieve this, you can run the ybbench in interactive mode using following docker run command. With interactive mode, you can modify the workload specific params for respective workload and run the benchmark.
   ```shell
    docker run --name ybbench --rm -it yugabytedb/ybbench:latest bash
    
    #inside the docker container, the code is located in /home/centos/code
    cd /home/centos/code/<benchmark_repo_name>
   ```

<img src="https://www.yugabyte.com/wp-content/uploads/2021/05/yb_horizontal_alt_color_RGB.png" align="center" alt="YugabyteDB" width="50%"/>

---------------------------------------