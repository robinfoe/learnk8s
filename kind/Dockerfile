FROM kindest/node:v1.19.1


RUN apt-get -y update && \
    apt-get -y install vim


ENTRYPOINT [ "/usr/local/bin/entrypoint", "/sbin/init"]
