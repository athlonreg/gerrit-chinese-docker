FROM centos:7.2.1511
MAINTAINER zhanghl

RUN yum -y install initscripts sudo git gitweb
# ADD jdk-8u161-linux-x64.rpm /usr/local
ADD gerrit-2.16.3-1.noarch.rpm /usr/local
ADD gerrit-2.16.3-1-Chinese-v8.war /usr/local
RUN cd /usr/local/
RUN rpm -ivh http://devops.iamzhl.top/file/jdk-8u161-linux-x64.rpm
RUN echo "JAVA_HOME=/usr/java/jdk1.8.0_161" >> /etc/profile
RUN echo "CLASSPATH=.:\$JAVA_HOME/lib:\$JAVA_HOME/lib/tools.jar" >> /etc/profile
RUN echo "PATH=\$PATH:\$JAVA_HOME/bin" >> /etc/profile
# RUN yum -y install java-1.8.0-openjdk
# RUN echo "JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk" >> /etc/profile
# RUN echo "CLASSPATH=.:\$JAVA_HOME/lib:\$JAVA_HOME/lib/tools.jar" >> /etc/profile
# RUN echo "PATH=\$PATH:\$JAVA_HOME/bin" >> /etc/profile
RUN source /etc/profile

# Add Gerrit packages repository
RUN rpm -ivh /usr/local/gerrit-2.16.3-1.noarch.rpm
RUN rm -f /var/gerrit/logs/*

USER gerrit
RUN java -jar /usr/local/gerrit-2.16.3-1-Chinese-v8.war init --batch --install-all-plugins -d /var/gerrit
ADD mysql-connector-java-5.1.43.jar /var/gerrit/lib
RUN java -jar /usr/local/gerrit-2.16.3-1-Chinese-v8.war reindex -d /var/gerrit
RUN git config -f /var/gerrit/etc/gerrit.config --add container.javaOptions "-Djava.security.egd=file:/dev/./urandom"

ENV CANONICAL_WEB_URL=

# Allow incoming traffic
EXPOSE 29418 8081

VOLUME ["/var/gerrit/git", "/var/gerrit/index", "/var/gerrit/cache", "/var/gerrit/db", "/var/gerrit/etc"]

# Start Gerrit
CMD git config -f /var/gerrit/etc/gerrit.config gerrit.canonicalWebUrl "${CANONICAL_WEB_URL:-http://$HOSTNAME}" && \
    git config -f /var/gerrit/etc/gerrit.config noteDb.changes.autoMigrate true && \
        /var/gerrit/bin/gerrit.sh run
