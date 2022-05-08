# Stable version of etherpad doesn't support npm 2

FROM node:18.1
MAINTAINER Glenn Y. Rolland <glenux@glenux.net>

ENV ETHERPAD_VERSION 1.8.18

# RUN = docker run ... + docker commit 
RUN apt-get update \
 && apt-get install -y curl unzip mariadb-client netcat \
 && apt-get clean \
 && rm -r /var/lib/apt/lists/*

WORKDIR /opt/

RUN curl -SL \
    https://github.com/ether/etherpad-lite/archive/${ETHERPAD_VERSION}.zip \
    > etherpad.zip && unzip etherpad \
 && rm etherpad.zip \
 && mv etherpad-lite-${ETHERPAD_VERSION} etherpad-lite

WORKDIR /opt/etherpad-lite

COPY parseurl.py /parseurl.py
COPY entrypoint.sh /entrypoint.sh

# Pre-install 
RUN chmod +x /entrypoint.sh \
 && npm install \
 	ep_author_neat ep_headings2 \
 	ep_set_title_on_pad ep_adminpads \
 	ep_workspaces ep_comments_page \
 	ep_font_color ep_table_of_contents \
 	ep_delete_after_delay \
 	ep_offline_edit \
 	ep_prompt_for_name \
 && bin/installDeps.sh \
 && sed -i 's/^node/exec\ node/' bin/run.sh \
 && rm settings.json \
 && ln -s var/settings.json settings.json

# ep_mypads 

# meta-données
VOLUME /opt/etherpad-lite/var
EXPOSE 9001
ENTRYPOINT ["/entrypoint.sh"]
CMD ["bin/run.sh", "--root"]

