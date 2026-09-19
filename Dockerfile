FROM nginx:1.27-alpine

# Filled in by the pipeline so the page shows which commit is live
ARG GIT_SHA=local
ARG BUILD_TIME=unknown

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY app/ /usr/share/nginx/html/

RUN sed -i "s|__GIT_SHA__|${GIT_SHA}|g; s|__BUILD_TIME__|${BUILD_TIME}|g" /usr/share/nginx/html/index.html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD wget -qO- http://localhost/health || exit 1
