# Stable version of etherpad doesn't support npm 2
FROM node:12-slim
MAINTAINER Glenn Y. Rolland <glenux@glenux.net>

ENV ETHERPAD_VERSION 1.8.4

# RUN = docker run ... + docker commit 
RUN apt-get update && \
    apt-get install -y curl unzip mysql-client python netcat && \
    rm -r /var/lib/apt/lists/*

WORKDIR /opt/

RUN curl -SL \
    https://github.com/ether/etherpad-lite/archive/${ETHERPAD_VERSION}.zip \
    > etherpad.zip && unzip etherpad && \
    rm etherpad.zip && \
    mv etherpad-lite-${ETHERPAD_VERSION} etherpad-lite

WORKDIR /opt/etherpad-lite

COPY parseurl.py /parseurl.py
COPY entrypoint.sh /entrypoint.sh

# Pre-install 
RUN bin/installDeps.sh && rm settings.json \
 && chmod +x /entrypoint.sh \
 && sed -i 's/^node/exec\ node/' bin/run.sh \
 && ln -s var/settings.json settings.json \
 && npm install ep_author_neat ep_headings2 ep_set_title_on_pad ep_adminpads ep_mypads ep_padwiki ep_comments_page

# meta-données
VOLUME /opt/etherpad-lite/var
EXPOSE 9001
ENTRYPOINT ["/entrypoint.sh"]
CMD ["bin/run.sh", "--root"]

