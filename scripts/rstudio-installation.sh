#!/bin/bash

s3Repo=$1

echo "S3 repo path: "$s3Repo

# Configure RStudio Server user
useradd -m rstudio
#password=`curl http://169.254.169.254/latest/meta-data/instance-id`
password="teste123"
echo rstudio:$password | sudo chpasswd
cd /home/rstudio
mkdir download

# Install R
yum install -y \
  gcc \
  gcc-c++ \
  gcc-gfortran \
  readline-devel \
  cairo-devel \
  libpng-devel \
  libjpeg-devel \
  libtiff-devel \
  openssl-devel \
  libxml2-devel \
  xorg-x11-xauth.x86_64 \
  xorg-x11-server-utils.x86_64 \
  xterm \
  libXt \
  libX11-devel \
  libXt-devel \
  libcurl-devel \
  git \
  compat-gmp4 \
  compat-libffi5 \
  wget

wget https://cdn.rstudio.com/r/centos-7/pkgs/R-4.0.0-1-1.x86_64.rpm -P download/
yum install -y download/R-4.0.0-1-1.x86_64.rpm
rm download/R-4.0.0-1-1.x86_64.rpm
ln -s /opt/R/4.0.0/bin/R /usr/local/bin/R
ln -s /opt/R/4.0.0/bin/Rscript /usr/local/bin/Rscript

# Install RStudio

wget https://download2.rstudio.org/server/centos6/x86_64/rstudio-server-rhel-1.3.1073-x86_64.rpm -P download/
yum install -y download/rstudio-server-rhel-1.3.1073-x86_64.rpm

# Install R packages for Spark
R -e 'install.packages(c("sparklyr", "dplyr", "ggplot2"), repos="http://cran.rstudio.com")'
rstudio-server verify-installation
rstudio-server stop

# Upgrade Java
yum install -y java-1.8.0
yum remove -y java-1.7.0-openjdk

# Install Scala
wget https://downloads.lightbend.com/scala/2.12.8/scala-2.12.8.rpm -P download/
yum install -y download/scala-2.12.8.rpm

# Install Hadoop
wget https://www.apache.org/dyn/closer.cgi/hadoop/common/hadoop-3.2.1/hadoop-3.2.1.tar.gz -P download/
tar xfz download/hadoop-3.2.1.tar.gz
ln -s /home/rstudio/hadoop-3.2.1 /usr/lib/hadoop
rm -rf /usr/lib/hadoop/share/doc*

# Install Spark
wget https://archive.apache.org/dist/spark/spark-2.4.4/spark-2.4.4-bin-without-hadoop-scala-2.12.tgz -P download
tar xfz download/spark-2.4.4-bin-without-hadoop-scala-2.12.tgz
ln -s /home/rstudio/spark-2.4.4-bin-without-hadoop-scala-2.12 /usr/lib/spark

#
# add AWS EMR Client deps from root
#
cd /

# Waiting for EMR client dependencies to be uploaded, timeout after 20 minutes
fileDeps=awsemrdeps.tgz
emrDepsFilePath=$s3UploadPath/$fileDeps

echo "Waiting for: "$emrDepsFilePath
waitTime=0
exists=$(aws s3 ls $emrDepsFilePath)
while [ "$waitTime" -lt 1800 -a  -z "$exists" ]; do
    waitTime=$((waitTime+5))
	echo "Waiting for "$emrDepsFilePath
	sleep 5
	exists=$(aws s3 ls $emrDepsFilePath)
done

aws s3 cp $emrDepsFilePath .
tar xfz ${fileDeps}
rm -f ${fileDeps}

# Client will create directories under /mnt for buffering
chmod 777 /mnt

# Configure environment variables for user & R
echo "export SCALA_HOME=/usr/share/scala" >> /home/rstudio/.bashrc
echo "export SPARK_HOME=/usr/lib/spark"  >> /home/rstudio/.bashrc
echo "export HADOOP_HOME=/usr/lib/hadoop" >> /home/rstudio/.bashrc
echo "export HADOOP_CONF_DIR=/usr/lib/hadoop/etc/hadoop" >> /home/rstudio/.bashrc
echo "export JAVA_HOME=/etc/alternatives/jre" >> /home/rstudio/.bashrc

echo "SCALA_HOME=/usr/share/scala" >> /home/rstudio/.Renviron
echo "SPARK_HOME=/usr/lib/spark"  >> /home/rstudio/.Renviron
echo "HADOOP_HOME=/usr/lib/hadoop" >> /home/rstudio/.Renviron
echo "HADOOP_CONF_DIR=/usr/lib/hadoop/etc/hadoop" >> /home/rstudio/.Renviron
echo "JAVA_HOME=/etc/alternatives/jre" >> /home/rstudio/.Renviron

# The default SQL catalog implementation for Spark 2.3.x+ is "in-memory" instead of "hive". The sparklyr library cannot properly cope with correctly setting/enabling hive-support programmatically.
echo "spark.sql.catalogImplementation   hive"   >> /etc/spark/conf/spark-defaults.conf

# Update config to reflect public IP address (optional)
RStudioServerPort=8787
RStudioServerHost=`curl http://169.254.169.254/latest/meta-data/public-hostname`
echo "www-port=$RStudioServerPort" >> /etc/rstudio/rserver.conf
echo "www-address=$RStudioServerHost" >> /etc/rstudio/rserver.conf

# Change ownership back to rstudio
chown -R rstudio:rstudio /home/rstudio

# Restart RStudio Server
rstudio-server start
echo "Finished installation of RStudio Server"
