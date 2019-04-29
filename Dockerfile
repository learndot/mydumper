FROM alpine:3.7

ENV LIB_PACKAGES='glib mariadb-client-libs mariadb-client pcre python2 bash curl rsync' \
    BUILD_PACKAGES='glib-dev mariadb-dev zlib-dev pcre-dev libressl-dev cmake build-base py2-pip'

RUN apk add --no-cache --update $LIB_PACKAGES $BUILD_PACKAGES \
  && cd /tmp \
  && export MYDUMPER_VERSION=$(curl -s "https://api.github.com/repos/maxbube/mydumper/releases/latest" | grep tag_name | cut -d '"' -f 4) \
  && wget "https://github.com/maxbube/mydumper/archive/$MYDUMPER_VERSION.tar.gz" -O mydumper.tar.gz \
  && tar -xzf mydumper.tar.gz \
  && cd mydumper* \
  && cmake . \
  && make \
  && make install \
  && pip install awscli \
  && apk del $BUILD_PACKAGES \
  && (rm -rf /tmp/* 2>/dev/null || true) \
  && (rm -rf /var/cache/apk/* 2>/dev/null || true)

COPY ./scripts /scripts
WORKDIR /scripts

ENTRYPOINT ["/bin/bash"]
CMD ["-c", "if [ ! -z $SCRIPT_URL ]; then curl --silent $SCRIPT_URL -o script && chmod +x script && ./script; fi"]
