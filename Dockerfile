# Stable version of etherpad doesn't support npm 2

FROM node:18.1
MAINTAINER Glenn Y. Rolland <glenux@glenux.net>

ENV ETHERPAD_VERSION 1.8.18

RUN apt-get update \
 && apt-get install -y unzip mariadb-client netcat \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
 && truncate -s 0 /var/log/*log

RUN cd /opt \
 && wget \
      https://github.com/ether/etherpad-lite/archive/${ETHERPAD_VERSION}.zip \
      -O etherpad.zip \
 && unzip etherpad \
 && rm etherpad.zip \
 && mv etherpad-lite-${ETHERPAD_VERSION} etherpad \
 && useradd --home-dir /opt/etherpad etherpad \
 && chown -R etherpad:etherpad /opt/etherpad

COPY --chown=etherpad parseurl.sh /parseurl.sh
COPY --chown=etherpad entrypoint.sh /entrypoint.sh


WORKDIR /opt/etherpad
USER etherpad

# Pre-install some plugins
RUN bin/installDeps.sh \
 && cd src \
 && npm install --save-prod \
      github:alxndr42/ep_expiration \
      ep_author_neat \
      ep_headings2 \
      ep_comments_page \
      ep_font_color \
      ep_offline_edit \
      ep_prompt_for_name \
      ep_workspaces \
      ep_table_of_contents \
      ep_adminpads \
 && cd .. \
 && rm settings.json \
 && ln -s var/settings.json settings.json

#     ep_delete_after_delay \
#     ep_set_title_on_pad \

# && sed -i 's/^node/exec\ node/' bin/run.sh \

# ep_mypads 

# meta-données
VOLUME /opt/etherpad/var
EXPOSE 9001

ENTRYPOINT ["/entrypoint.sh"]
CMD ["./src/bin/run.sh"]
# bin/run.sh

