FROM openhab/openhab:5.1.2-debian

ARG GRAALPY_VERSION=25.0.1
ARG GRAALPY_DIST=linux-amd64
ENV GRAALPY_HOME=/opt/graalpy
ENV PYTHON_VENV_PATH=/openhab/userdata/cache/org.openhab.automation.pythonscripting/venv
ENV PATH="${GRAALPY_HOME}/bin:${PATH}"

LABEL org.openhab.version="5.1.2" \
      org.openhab.graalpy.version="${GRAALPY_VERSION}"

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gzip \
        patchelf \
        tar \
        xz-utils; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir -p /opt; \
    curl -fsSL https://github.com/oracle/graalpython/releases/download/graal-${GRAALPY_VERSION}/graalpy-community-${GRAALPY_VERSION}-${GRAALPY_DIST}.tar.gz \
        | tar -xzf - -C /opt; \
    mv /opt/graalpy-community-${GRAALPY_VERSION}-${GRAALPY_DIST} "${GRAALPY_HOME}"; 

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["su-exec", "openhab", "tini", "-s", "./start.sh"]