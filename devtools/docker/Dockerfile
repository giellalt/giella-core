# Minimal dockerfile to test giellalt stuffs fast

FROM ubuntu:latest
MAINTAINER Flammie A Pirinen <flammie@iki.fi>

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential automake autoconf git wget lsb-release libtool zip pkg-config\
    libsaxonb-java python3-pip python3-lxml python3-bs4 python3-html5lib \
    libxml-twig-perl antiword xsltproc poppler-utils python3-svn wv \
    python3-feedparser subversion openjdk-11-jdk cmake \
    python3-tidylib python3-yaml libxml-libxml-perl libtext-brew-perl \
    icu-devtools &&\
    wget http://apertium.projectjj.com/apt/install-nightly.sh -O - | bash && \
    DEBIAN_FRONTEND=noninteractive  apt-get install -y apertium-all-dev \
    python3-hfst libhfst-dev cg3 && \
    mkdir github && \
    mkdir github/giellalt && \
    for repo in giella-core lang-sme lang-sma lang-smj lang-smn lang-sms ; do \
    git clone https://github.com/giellalt/$repo github/giellalt/$repo ;\
    done

