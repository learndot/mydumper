FROM gcc:8 as builder
RUN curl https://cmake.org/files/v3.12/cmake-3.12.0-Linux-x86_64.sh -o /tmp/curl-install.sh \
      && chmod u+x /tmp/curl-install.sh \
      && mkdir /usr/bin/cmake \
      && /tmp/curl-install.sh --skip-license --prefix=/usr/bin/cmake \
      && rm /tmp/curl-install.sh
RUN bzr branch lp:mydumper
WORKDIR /mydumper
RUN /usr/bin/cmake/bin/cmake . && make

FROM ubuntu
RUN apt-get -y -q update \
        && apt-get install -y libglib2.0-0 mariadb-client libmariadbclient-dev python python-pip \
        && apt-get clean \
        && apt-get autoclean \
        && pip install awscli

COPY --from=builder /mydumper/mydumper /usr/bin/
COPY --from=builder /mydumper/myloader /usr/bin/
CMD ["/bin/bash"]
