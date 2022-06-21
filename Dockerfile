FROM registry.access.redhat.com/ubi8/nodejs-14:latest as build


COPY . /workspace/

ENV NPM_REGISTRY=" https://registry.npmjs.org"

RUN chgrp -R 0 /workspace/ && \
    chmod -R g=u /workspace/

RUN echo "registry = \"$NPM_REGISTRY\"" > /workspace/.npmrc                              && \
    cd /workspace/                                                                       && \
    npm install                                                                          && \
    npm run build

FROM registry.access.redhat.com/ubi8/nginx-118:latest AS runtime


COPY  --from=build /workspace/dist/ /usr/share/nginx/html/

RUN chmod a+rwx /var/cache/nginx /var/run /var/log/nginx                        && \
    sed -i.bak 's/listen\(.*\)80;/listen 8080;/' /etc/nginx/conf.d/default.conf && \
    sed -i.bak 's/^user/#user/' /etc/nginx/nginx.conf


EXPOSE 8080

USER 1001

HEALTHCHECK     CMD     [ "service", "nginx", "status" ]


