FROM ubi8/ubi
MAINTAINER flg <flg@redhat.com> 
#Install updates and pkgs needed
RUN yum --setopt=tsflags=nodocs install -y wget openssh-clients unzip java-11-openjdk-devel procps net-tools && \
    yum clean all -y

# enable sudo 
RUN echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
sed -i 's/.*requiretty$/Defaults |requiretty/' /etc/sudoers 

# add a app user and wildfly goup with sudo permissions

RUN groupadd -r wildfly -f -g 1001 && \
    useradd -u 1001 -r -g wildfly  -m -d /opt/wildfly wildfly && \ 
    echo wildfly: | chpasswd 

WORKDIR /opt/wildfly

#
ADD wildfly-27.0.1.Final.zip /opt/wildfly

# RUN wget https://github.com/wildfly/wildfly/releases/download/27.0.1.Final/wildfly-27.0.1.Final.zip


RUN unzip /opt/wildfly/wildfly-27.0.1.Final.zip


ENV JBOSS_HOME "/opt/wildfly/wildfly-27.0.1.Final"
#ADD Wildfly admin 

RUN ${JBOSS_HOME}/bin/add-user.sh admin flg@nomiras.com --silent 

# Add Jboss config 

RUN echo "JAVA_OPTS=\"$JAVA_OPTS -Djboss.bind.address=0.0.0.0 -Djboss.bind.address.management=0.0.0.0 -Djava.net.preferIPv4Stack\"" >> $JBOSS_HOME/bin/standalone.conf 

RUN chown -R wildfly:wildfly /opt/wildfly


ARG JBOSS_VERSION="7.4"

#RUN sysctl -w net.ipv6.conf.all.disable_ipv6=1

EXPOSE 8080
EXPOSE 9990
EXPOSE 9999

ENTRYPOINT ${JBOSS_HOME}/bin/standalone.sh -c standalone-full-ha.xml

USER wildfly
#COPY wildfly-eap-${JBOSS_VERSION} ${JBOSS_HOME}

CMD /bin/bash

