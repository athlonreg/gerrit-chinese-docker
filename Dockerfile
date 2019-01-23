FROM centos:7.5.1804
MAINTAINER canvas1996

RUN yum -y install sudo wget git

# Install jdk-8u161 and Gerrit
RUN wget -c https://media.githubusercontent.com/media/athlonreg/gerrit-chinese-docker/master/jdk-8u161-linux-x64.rpm
RUN wget -c https://raw.github.com/athlonreg/gerrit-chinese-docker/master/review_site.tar.gz
RUN rpm -ivh jdk-8u161-linux-x64.rpm
RUN mv review_site.tar.gz /usr/local/ && tar zxvf /usr/local/review_site.tar.gz -C /usr/local/ && rm -rf /usr/local/review_site.tar.gz
RUN wget -c -O /usr/local/review_site/lib/mysql-connector-java-5.1.43.jar https://raw.github.com/athlonreg/gerrit-chinese-docker/master/mysql-connector-java-5.1.43.jar
RUN chmod -R 755 /usr/local/review_site

RUN java -jar /usr/local/review_site/bin/gerrit.war init --batch --install-all-plugins -d /usr/local/review_site
RUN java -jar /usr/local/review_site/bin/gerrit.war reindex -d /usr/local/review_site
RUN git config -f /usr/local/review_site/etc/gerrit.config --add container.javaOptions "-Djava.security.egd=file:/dev/./urandom"

ENV CANONICAL_WEB_URL=

# Allow incoming traffic
EXPOSE 29418 8080
VOLUME ["/usr/local/review_site/git", "/usr/local/review_site/index", "/usr/local/review_site/cache", "/usr/local/review_site/gerrit/db", "/usr/local/review_site/etc"]

# Start Gerrit
CMD git config -f /usr/local/review_site/etc/gerrit.config gerrit.canonicalWebUrl "${CANONICAL_WEB_URL:-http://$HOSTNAME}" && \
    git config -f /usr/local/review_site/etc/gerrit.config noteDb.changes.autoMigrate true && \
        /usr/local/review_site/bin/gerrit.sh run
