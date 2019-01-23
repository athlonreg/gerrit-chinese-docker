FROM centos:7.5.1804
MAINTAINER canvas1996

RUN yum -y install initscripts sudo wget

# Add Gerrit packages repository
RUN rpm -i https://gerritforge.com/gerritforge-repo-1-2.noarch.rpm

# Install OpenJDK and Gerrit in two subsequent transactions
# (pre-trans Gerrit script needs to have access to the Java command)
RUN yum -y install java-1.8.0-openjdk
RUN yum -y install gerrit-2.16.3  && rm -f /var/gerrit/logs/*

RUN wget -c -O gerrit.war https://raw.github.com/athlonreg/gerrit-chinese-docker/master/gerrit-2.16.3-1-Chinese-v8.war

USER gerrit
RUN java -jar gerrit.war init --batch --install-all-plugins -d /var/gerrit
RUN java -jar gerrit.war reindex -d /var/gerrit
RUN git config -f /var/gerrit/etc/gerrit.config --add container.javaOptions "-Djava.security.egd=file:/dev/./urandom"

ENV CANONICAL_WEB_URL=

# Allow incoming traffic
EXPOSE 29418 8080

VOLUME ["/var/gerrit/git", "/var/gerrit/index", "/var/gerrit/cache", "/var/gerrit/db", "/var/gerrit/etc"]

# Start Gerrit
CMD git config -f /var/gerrit/etc/gerrit.config gerrit.canonicalWebUrl "${CANONICAL_WEB_URL:-http://$HOSTNAME}" && \
    git config -f /var/gerrit/etc/gerrit.config noteDb.changes.autoMigrate true && \
        /var/gerrit/bin/gerrit.sh run
