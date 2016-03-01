# FROM tmart2011/nginx-minimal:latest
FROM alpine:latest

MAINTAINER Ty Martin <ty.w.martin@gmail.com>

RUN apk add --update nginx \
  && rm -rf /var/cache/apk/* \
  && chown nginx:nginx /var/log/nginx

COPY nginx.conf /etc/nginx/nginx.conf
COPY public/ /usr/share/nginx/html

USER nginx

CMD ["nginx", "-g", "daemon off;"]
