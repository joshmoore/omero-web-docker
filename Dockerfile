FROM centos:centos7
MAINTAINER ome-devel@lists.openmicroscopy.org.uk

RUN mkdir /opt/setup
WORKDIR /opt/setup
ADD playbook.yml requirements.yml /opt/setup/

RUN yum -y install epel-release \
    && yum -y install ansible sudo \
    && ansible-galaxy install -p /opt/setup/roles -r requirements.yml

ARG OMERO_VERSION=latest
RUN ansible-playbook playbook.yml -e omero_web_release=$OMERO_VERSION

RUN curl -L -o /usr/local/bin/dumb-init \
    https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 && \
    chmod +x /usr/local/bin/dumb-init
ADD entrypoint.sh /usr/local/bin/
ADD 50-config.py 60-default-web-config.sh 99-run.sh /startup/

USER omero-web
RUN mkdir /opt/omero/web/OMERO.web/var

EXPOSE 4080
VOLUME ["/opt/omero/web/OMERO.web/var"]

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
