#!/bin/bash

emrClientDepsPath=${1%/}/emr-client
echo "EMR client dependencies path: "$emrClientDepsPath

cd /mnt
mkdir t
cd t

mkdir -p ./etc/hadoop/conf
cp -a /etc/hadoop/conf/yarn-site.xml ./etc/hadoop/conf/
cp -a /etc/hadoop/conf/core-site.xml ./etc/hadoop/conf/

mkdir -p ./etc/hive/conf
cp -a /etc/hive/conf/* ./etc/hive/conf/

mkdir -p ./etc/spark/conf
cp -a /etc/spark/conf/* ./etc/spark/conf/

mkdir -p ./usr/lib
cp -a /usr/lib/hbase ./usr/lib
cp -a /usr/lib/hadoop ./usr/lib
cp -a /usr/lib/hadoop-lzo ./usr/lib
cp -a /usr/lib/hadoop-hdfs ./usr/lib
cp -a /usr/lib/spark ./usr/lib
rm -f ./usr/lib/spark/work
mkdir ./usr/lib/spark/work

mkdir -p ./usr/share
cp -a /usr/share/aws ./usr/share

rm -rf ./usr/share/aws/emr/instance-controller
rm -rf ./usr/share/aws/emr/hadoop-state-pusher

tar cvfz ../awsemrdeps.tgz .
cd ..
aws s3 cp awsemrdeps.tgz $emrClientDepsPath/
