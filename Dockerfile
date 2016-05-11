FROM alpine:3.2

ENV JAVA_VERSION_MAJOR 8
ENV JAVA_VERSION_MINOR 72
ENV JAVA_VERSION_BUILD 15
ENV JAVA_PACKAGE server-jre
RUN apk add --no-cache --update --virtual=build-dependencies curl ca-certificates && \
 cd /tmp && \
 curl -o glibc-2.21-r2.apk "https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-2.21-r2.apk" && \
 apk add --allow-untrusted glibc-2.21-r2.apk && \
 curl -o glibc-bin-2.21-r2.apk "https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-bin-2.21-r2.apk" && \
 apk add --allow-untrusted glibc-bin-2.21-r2.apk && \
 /usr/glibc/usr/bin/ldconfig /lib /usr/glibc/usr/lib && \
 curl -jksSLH "Cookie: oraclelicense=accept-securebackup-cookie"\
  http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD}/${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz | gunzip -c - | tar -xf - 
RUN apk add bash && \
  apk del build-dependencies && \
  mv jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR}/jre /jre && \
  rm /jre/bin/jjs && \
  rm /jre/bin/keytool && \
  rm /jre/bin/orbd && \
  rm /jre/bin/pack200 && \
  rm /jre/bin/policytool && \
  rm /jre/bin/rmid && \
  rm /jre/bin/rmiregistry && \
  rm /jre/bin/servertool && \
  rm /jre/bin/tnameserv && \
  rm /jre/bin/unpack200 && \
  rm /jre/lib/ext/nashorn.jar && \
  rm /jre/lib/jfr.jar && \
  rm -rf /jre/lib/jfr && \
  rm -rf /jre/lib/oblique-fonts && \
  rm -rf /tmp/* /var/cache/apk/*
RUN curl http://apache.claz.org/hadoop/common/hadoop-2.7.2/hadoop-2.7.2.tar.gz | gunzip -c - | tar -xf -
RUN mv hadoop-2.7.2 /hadoop

RUN addgroup hadoop
RUN adduser -S hadoop -G hadoop

# Set environment
ENV JAVA_HOME /jre
ENV HADOOP_INSTALL=/hadoop
ENV PATH ${JAVA_HOME}/bin:${PATH}:${HADOOP_INSTALL}/bin:${HADOOP_INSTALL}/sbin
ENV HADOOP_CONF_DIR=/hadoop-conf

COPY ./spark /spark
COPY ./hadoop-conf /hadoop-conf
RUN chown -R hadoop.hadoop /hadoop /spark /hadoop-conf 

VOLUME ["/home/hadoop", "/hadoop-conf", "/tmp"]
USER hadoop
WORKDIR /home/hadoop
ENTRYPOINT ["hadoop"]
CMD ["--help"]
