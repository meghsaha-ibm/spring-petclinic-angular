FROM registry.access.redhat.com/ubi8/nodejs-14:latest as build

WORKDIR /usr/src/app

COPY . /usr/src/app/

ENV NPM_REGISTRY=" https://registry.npmjs.org"

RUN echo "registry = https://registry.npmjs.org" > /usr/src/app/.npmrc                              && \
    cd /usr/src/app/                                                                       && \
    npm install                                                                          && \
    npm run build

FROM registry.access.redhat.com/ubi8/nginx-118:latest AS runtime


COPY  --from=build /usr/src/app/dist/ /usr/share/nginx/html/

RUN chmod a+rwx /var/cache/nginx /var/run /var/log/nginx                        && \
    sed -i.bak 's/listen\(.*\)80;/listen 8080;/' /etc/nginx/conf.d/default.conf && \
    sed -i.bak 's/^user/#user/' /etc/nginx/nginx.conf


EXPOSE 8080

USER nginx

HEALTHCHECK     CMD     [ "service", "nginx", "status" ]
