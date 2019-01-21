FROM centos:7.5.1804
MAINTAINER zhanghl

RUN yum -y install git gitweb
COPY jdk-8u161-linux-x64.rpm /usr/local
# ADD gerrit-2.16.3-1.noarch.rpm /usr/local
COPY gerrit-2.16.3-1-Chinese-v8.war /usr/local
COPY review_site.tar.gz /usr/local
RUN cd /usr/local && tar zxvf /usr/local/review_site.tar.gz
RUN rpm -ivh /usr/local/jdk-8u161-linux-x64.rpm
RUN echo "JAVA_HOME=/usr/java/jdk1.8.0_161" >> /etc/profile
RUN echo "CLASSPATH=.:\$JAVA_HOME/lib:\$JAVA_HOME/lib/tools.jar" >> /etc/profile
RUN echo "PATH=\$PATH:\$JAVA_HOME/bin" >> /etc/profile
# RUN yum -y install java-1.8.0-openjdk
# RUN echo "JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk" >> /etc/profile
# RUN echo "CLASSPATH=.:\$JAVA_HOME/lib:\$JAVA_HOME/lib/tools.jar" >> /etc/profile
# RUN echo "PATH=\$PATH:\$JAVA_HOME/bin" >> /etc/profile
RUN source /etc/profile

# Add Gerrit packages repository
# RUN rpm -ivh /usr/local/gerrit-2.16.3-1.noarch.rpm
RUN rm -f /usr/local/review_site/logs/*

USER root
RUN java -jar /usr/local/gerrit-2.16.3-1-Chinese-v8.war init --batch --install-all-plugins -d /usr/local/review_site
ADD mysql-connector-java-5.1.43.jar /usr/local/review_site/lib
RUN java -jar /usr/local/gerrit-2.16.3-1-Chinese-v8.war reindex -d /usr/local/review_site
RUN git config -f /usr/local/review_site/etc/gerrit.config --add container.javaOptions "-Djava.security.egd=file:/dev/./urandom"

ENV CANONICAL_WEB_URL=http://localhost:8081/

# Allow incoming traffic
EXPOSE 29418 8081

VOLUME ["/usr/local/review_site/git", "/usr/local/review_site/index", "/usr/local/review_site/cache", "/usr/local/review_site/db", "/usr/local/review_site/etc"]

# Start Gerrit
CMD git config -f /usr/local/review_site/etc/gerrit.config gerrit.canonicalWebUrl "${CANONICAL_WEB_URL:-http://localhost:8081}" && \
    git config -f /usr/local/review_site/etc/gerrit.config noteDb.changes.autoMigrate true && \
        /usr/local/review_site/bin/gerrit.sh run
