FROM nginxinc/nginx-unprivileged:1.31.3-alpine-slim

COPY --chown=101:101 app/ /usr/share/nginx/html/

EXPOSE 8080

USER 101:101

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://127.0.0.1:8080/healthz || exit 1
