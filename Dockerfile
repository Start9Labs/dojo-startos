FROM --platform=linux/arm64/v8 louneskmt/dojo-db:1.5.0-low-mem@sha256:f8177b79b3042c494ab15c032641c0424da2375dfd486c516cdc6206b3ffeb93 as database

FROM --platform=linux/arm64/v8 louneskmt/whirlpool:0.10.15@sha256:5a5842dbd2123906205408d119cffd803fe703bbcbc60dc1c47ae39b33457b12 as whirlpool

FROM --platform=linux/arm64/v8 louneskmt/dojo-nodejs:1.16.1@sha256:7caf408c6ed2b4b6b46c4d7b28ffce12b3793fdb3ec609a46e89e0e00109e1f7 as dojo

FROM --platform=linux/arm64/v8 nginx:1.21-alpine@sha256:07412f4c3c727ccdfac16006c7c28ce77a80c39372545ce5edd877be92f533dd as final

USER root

RUN apk add tini bash curl yq nginx && rm -f /var/cache/apk/*

COPY --from=database /var/lib/mysql /var/lib/mysql
COPY --from=whirlpool /home/whirlpool/.whirlpool-cli /home/whirlpool/.whirlpool-cli
COPY --from=dojo /home/node/app/ /home/node/app/

ADD user.conf /root/.config/RoninDojo/user.conf
ADD docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh
RUN chmod a+x /usr/local/bin/*.sh
