# Copyright (c) YugaByte, Inc.

FROM almalinux:8

ARG tpcc_branch=master
ARG sysbench_branch=master
ARG sample_apps_branch=master
ARG ycsb_branch=master

WORKDIR /home/centos
COPY . .

WORKDIR /home/centos/code
# install required binaries
RUN yum install -y java-1.8.0-openjdk-devel wget git vim unzip maven python2
RUN yum install -y make automake libtool pkgconfig libaio-devel postgresql-devel
RUN ln -sf /usr/bin/python2 /usr/bin/python

# install ant
RUN wget https://downloads.apache.org//ant/binaries/apache-ant-1.9.16-bin.zip
RUN unzip apache-ant-*
RUN mv apache-ant-1.9.16 /opt/ant
RUN ln -s /opt/ant/bin/ant /usr/bin/ant

# clone required github repositories
RUN git clone https://github.com/yugabyte/tpcc.git -b $tpcc_branch
RUN git clone https://github.com/yugabyte/sysbench.git -b $sysbench_branch
RUN git clone https://github.com/yugabyte/yb-sample-apps.git -b $sample_apps_branch
RUN git clone https://github.com/yugabyte/YCSB.git -b $ycsb_branch

# build tpcc code
WORKDIR /home/centos/code/tpcc
RUN ant bootstrap
RUN ant resolve
RUN ant build
RUN rm -rf .git src stand-alone-testing-of-alt-sql-from-proc-solns tools build.xml ivy.xml ivysettings.xml manifest.mf run_scripts tpcc.iml pom.xml 

# build the sysbench code
WORKDIR /home/centos/code/sysbench
RUN ./autogen.sh
RUN ./configure --without-mysql --with-pgsql
RUN make -j
RUN make install
RUN rm -rf .git

# build the yb-sample-apps jar
WORKDIR /home/centos/code/yb-sample-apps
RUN mvn -DskipTests -DskipDockerBuild package
RUN cp target/yb-sample-apps.jar /home/centos/code

# TODO: build the ycsb code
WORKDIR /home/centos/code/YCSB
RUN mvn -pl yugabyteSQL,yugabyteCQL -am clean package -DskipTests
RUN rm -rf .git

# change the working direcotry
WORKDIR /home/centos
RUN rm -rf code/apache-ant* code/yb-sample-apps

# change the runner file permissions
RUN chmod 777 run
CMD ["./run", "-h"]
