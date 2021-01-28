#!/bin/bash

# Configure environment variables for user & R
echo "export SCALA_HOME=/usr/share/scala" >> /home/rstudio/.bashrc
echo "export SPARK_HOME=/usr/lib/spark"  >> /home/rstudio/.bashrc
echo "export HADOOP_HOME=/usr/lib/hadoop" >> /home/rstudio/.bashrc
echo "export HADOOP_CONF_DIR=/usr/lib/hadoop/etc/hadoop" >> /home/rstudio/.bashrc
echo "export JAVA_HOME=/etc/alternatives/jre" >> /home/rstudio/.bashrc

cat << 'EOF' > /tmp/Renvextra
JAVA_HOME="/etc/alternatives/jre"
HADOOP_HOME_WARN_SUPPRESS="true"
HADOOP_HOME="/usr/lib/hadoop"
HADOOP_PREFIX="/usr/lib/hadoop"
HADOOP_MAPRED_HOME="/usr/lib/hadoop-mapreduce"
HADOOP_YARN_HOME="/usr/lib/hadoop-yarn"
HADOOP_COMMON_HOME="/usr/lib/hadoop"
HADOOP_HDFS_HOME="/usr/lib/hadoop-hdfs"
YARN_HOME="/usr/lib/hadoop-yarn"
HADOOP_CONF_DIR="/usr/lib/hadoop/etc/hadoop/"
YARN_CONF_DIR="/usr/lib/hadoop/etc/hadoop/"

HIVE_HOME="/usr/lib/hive"
HIVE_CONF_DIR="/usr/lib/hive/conf"

HBASE_HOME="/usr/lib/hbase"
HBASE_CONF_DIR="/usr/lib/hbase/conf"

SPARK_HOME="/usr/lib/spark"
SPARK_CONF_DIR="/usr/lib/spark/conf"

PATH=${PWD}:${PATH}
EOF

cat /tmp/Renvextra | sudo  tee -a /opt/R/4.0.3/lib/R/etc/Renviron