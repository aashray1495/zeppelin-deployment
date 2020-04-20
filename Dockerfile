FROM ubuntu:16.04

ENV Z_VERSION="0.8.0"
ENV LOG_TAG="[ZEPPELIN_${Z_VERSION}]:" \
    Z_HOME="/zeppelin" \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8
ARG SPARK_VERSION="2.3.4"
ARG HADOOP_VERSION="2.7"

LABEL maintainer "aashrayyadav@lucidmotos.com"
LABEL spark.version=${SPARK_VERSION}
LABEL hadoop.version=${HADOOP_VERSION}


RUN echo "$LOG_TAG update and install basic packages" && \
    apt-get -y update && \
    apt-get install -y locales && \
    locale-gen $LANG && \
    apt-get install -y software-properties-common && \
    apt -y autoclean && \
    apt -y dist-upgrade && \
    apt-get install -y build-essential

RUN echo "$LOG_TAG install tini related packages" && \
    apt-get install -y wget curl grep sed dpkg && \
    TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
RUN echo "$LOG_TAG Install java8" && \
    apt-get -y update && \
    apt-get install -y openjdk-8-jdk && \
    rm -rf /var/lib/apt/lists/*

# should install conda first before numpy, matploylib since pip and python will be installed by conda
# RUN echo "$LOG_TAG Install miniconda2 related packages" && \
#     apt-get -y update && \
#     apt-get install -y bzip2 ca-certificates \
#     libglib2.0-0 libxext6 libsm6 libxrender1 \
#     git mercurial subversion && \
#     echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
#     wget --quiet https://repo.continuum.io/miniconda/Miniconda2-4.2.12-Linux-x86_64.sh -O ~/miniconda.sh && \
#     /bin/bash ~/miniconda.sh -b -p /opt/conda && \
#     rm ~/miniconda.sh
# ENV PATH /opt/conda/bin:$PATH

RUN apt-get update\
    && apt-get install -y python-pip
RUN pip install --upgrade pip
RUN pip install -U "flask==1.0.3" && \
    pip install -U "Werkzeug==0.14.1" && \
    pip install -U "Jinja2<2.11.0,>=2.10.1" && \
#    pip install -U "simple-salesforce==0.74.3" && \
    pip install -U "alembic<2.0,>=1.0" && \
##    pip install -U "simple-salesforce==0.74.3" && \
    pip install -U "pendulum==1.4.4" && \
    #pip install -U "pyodbc==4.0.27" && \
    pip install -U "boto3==1.9.218" && \
    #pip install -U "logging==0.4.9.6" && \
    pip install -U "pyyaml" && \
    pip install -U "smart_open" && \
    pip install -U "numpy==1.16.5" && \
    pip install -U "pandas==0.24.2" && \
    pip install -U "elasticsearch==7.1.0" && \
    pip install -U "pandasticsearch==0.5.3" && \
    pip install -U "certifi==2019.9.11"
# RUN echo "$LOG_TAG Install python related packages" && \
#     apt-get -y update && \
#     apt-get install -y python-dev python-pip && \
#     # apt-get install -y gfortran && \
#     # numerical/algebra packages
#     apt-get install -y libblas-dev libatlas-dev liblapack-dev && \
#     # font, image for matplotlib
#     apt-get install -y libpng-dev libfreetype6-dev libxft-dev && \
#     # for tkinter
#     apt-get install -y python-tk libxml2-dev libxslt-dev zlib1g-dev && \
#     conda config --set always_yes yes --set changeps1 no && \
#     conda update -q conda && \
#     conda info -a && \
#     conda config --add channels conda-forge && \
#     conda install -q numpy=1.13.3 pandas=0.21.1 matplotlib=2.1.1 pandasql=0.7.3 ipython=5.4.1 jupyter_client=5.1.0 ipykernel=4.7.0 bokeh=0.12.10 && \
#     pip install -q scipy==0.18.0 ggplot==0.11.5 grpcio==1.8.2 bkzep==0.4.0

# RUN echo "$LOG_TAG Install R related packages" && \
#     echo "deb http://cran.rstudio.com/bin/linux/ubuntu xenial/" | tee -a /etc/apt/sources.list && \
#     gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9 && \
#     gpg -a --export E084DAB9 | apt-key add - && \
#     apt-get -y update && \
#     apt-get -y --allow-unauthenticated install r-base r-base-dev && \
#     R -e "install.packages('knitr', repos='http://cran.us.r-project.org')" && \
#     R -e "install.packages('ggplot2', repos='http://cran.us.r-project.org')" && \
#     R -e "install.packages('googleVis', repos='http://cran.us.r-project.org')" && \
#     R -e "install.packages('data.table', repos='http://cran.us.r-project.org')" && \
#     # for devtools, Rcpp
#     apt-get -y install libcurl4-gnutls-dev libssl-dev && \
#     R -e "install.packages('devtools', repos='http://cran.us.r-project.org')" && \
#     R -e "install.packages('Rcpp', repos='http://cran.us.r-project.org')" && \
#     Rscript -e "library('devtools'); library('Rcpp'); install_github('ramnathv/rCharts')"
#
RUN echo "$LOG_TAG Download Zeppelin binary" && \
    wget -O /tmp/zeppelin-${Z_VERSION}-bin-all.tgz http://archive.apache.org/dist/zeppelin/zeppelin-${Z_VERSION}/zeppelin-${Z_VERSION}-bin-all.tgz && \
    tar -zxvf /tmp/zeppelin-${Z_VERSION}-bin-all.tgz && \
    rm -rf /tmp/zeppelin-${Z_VERSION}-bin-all.tgz && \
    mv /zeppelin-${Z_VERSION}-bin-all ${Z_HOME}

RUN echo "$LOG_TAG Cleanup" && \
    apt-get autoclean && \
    apt-get clean


# Install Java and some tools
RUN apt-get -y update &&\
    apt-get -y install curl less &&\
    apt-get install -y openjdk-8-jdk &&\
    apt-get -y install vim


##########################################
# SPARK
##########################################
ARG SPARK_ARCHIVE=http://artfiles.org/apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz
RUN mkdir /usr/local/spark &&\
    mkdir /tmp/spark-events    # log-events for spark history server
ENV SPARK_HOME /usr/local/spark

ENV PATH $PATH:${SPARK_HOME}/bin
RUN curl -s ${SPARK_ARCHIVE} | tar -xz -C  /usr/local/spark --strip-components=1

COPY spark-defaults.conf ${SPARK_HOME}/conf/




EXPOSE 8080



ENTRYPOINT [ "/usr/bin/tini", "--" ]
WORKDIR ${Z_HOME}
CMD ["bin/zeppelin.sh"]
