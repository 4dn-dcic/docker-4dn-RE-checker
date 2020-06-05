FROM ubuntu:16.04
MAINTAINER Soo Lee (duplexa@gmail.com) Clara Bakker (Clara_Bakker@hms.harvard.edu)

# 1. general updates & installing necessary Linux components
RUN apt-get update -y && apt-get install -y \
    bzip2 \
    gcc \
    git \
    less \
    libncurses-dev \
    make \
    time \
    unzip \
    vim \
    wget \
    zlib1g-dev \
    liblz4-tool \
    libbz2-dev \
    liblzma-dev

WORKDIR /usr/local/bin

RUN wget https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2 && \
    tar -xjf samtools-1.9.tar.bz2 && \
    cd samtools-1.9 && \
    ./configure && \
    make && \
    cd .. && \
    ln -s samtools-1.9 samtools

COPY scripts/ .
RUN chmod +x run*.sh
RUN chmod +x *.pl

ENV PATH=/usr/local/bin/samtools/:$PATH
ENV PATH=/usr/local/bin/scripts/:$PATH
ENV PATH=/usr/local/perl/:$PATH

CMD ["bash"]
