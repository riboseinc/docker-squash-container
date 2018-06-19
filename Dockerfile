FROM centos:7
MAINTAINER Operations at Ribose <operations@ribose.com>

RUN yum install -y epel-release; \
  yum -y update; \
  yum install -y python-pip docker; \
  yum clean all

RUN \
  pip install --upgrade pip; \
  pip install docker-squash; \
  pip install "docker<3.0.0"

VOLUME ["/docker_tmp"]

ENTRYPOINT ["docker-squash", "--tmp-dir", "/docker_tmp/squash"]

