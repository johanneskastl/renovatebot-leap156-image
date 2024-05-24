FROM registry.opensuse.org/opensuse/leap:15.6

ARG RENOVATE_VERSION=37.374.3

#
# prepare for installation
#
USER root
RUN mkdir -p /opt/ && \
     mkdir -p /opt/containerbase && \
     mkdir -p /opt/containerbase/tools/ && \
     mkdir -p /opt/containerbase/tools/renovate && \
     mkdir -p /opt/containerbase/versions/

RUN zypper ref && \
     zypper -n install --no-recommends bash curl gawk coreutils sed nodejs20 npm20 git-core findutils && \
     zypper -n clean && \
     rm -rf /var/log/{lastlog,tallylog,zypper.log,zypp/history,YaST2}

#
# install helpers in /usr/local/bin/
#
WORKDIR /usr/local/bin/
RUN echo ${RENOVATE_VERSION} && curl -L --silent -o renovate https://raw.githubusercontent.com/renovatebot/renovate/${RENOVATE_VERSION}/tools/docker/bin/renovate && \
    curl -L --silent -o renovate-config-validator https://raw.githubusercontent.com/renovatebot/renovate/${RENOVATE_VERSION}/tools/docker/bin/renovate-config-validator && \
    curl -L --silent -o docker-entrypoint.sh https://raw.githubusercontent.com/renovatebot/renovate/${RENOVATE_VERSION}/tools/docker/bin/docker-entrypoint.sh && \
    chmod +x renovate docker-entrypoint.sh renovate-config-validator

#
# install renovate
#
WORKDIR /usr/local/renovate/
RUN npm install renovate && \
    rm -rf /root/.npm/ && \
    ln -s /usr/local/renovate/node_modules/renovate/dist /usr/local/renovate/

#
# environment settings
#
WORKDIR /usr/src/app
RUN set -ex; \
    echo "${RENOVATE_VERSION}" > /opt/containerbase/versions/renovate; \
    ln -sf /usr/local/renovate /opt/containerbase/tools/renovate/${RENOVATE_VERSION}; \
    ln -sf /usr/local/renovate/node_modules ./node_modules; \
    true

ENV RENOVATE_X_IGNORE_NODE_WARN=true

#
# final tests
#
RUN node "${RENOVATE_NODE_ARGS[@]}" /usr/local/renovate/dist/renovate.js --version
RUN set -ex; \
  renovate --version; \
  renovate-config-validator; \
  node -e "new require('re2')('.*').exec('test')"; \
  true

LABEL name="renovatebot-leap156-image"
LABEL org.opencontainers.image.source="https://github.com/johanneskastl/renovatebot-leap156-image" \
  org.opencontainers.image.url="https://github.com/johanneskastl/renovatebot-leap156-image" \
  org.opencontainers.image.licenses="AGPL-3.0-only"
LABEL \
  org.opencontainers.image.version="${RENOVATE_VERSION}" \
  org.label-schema.version="${RENOVATE_VERSION}"

# finished building
USER 1000
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["renovate"]
