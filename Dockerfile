ARG VERSION=unspecified

FROM python:3.10.7-alpine3.16

ARG VERSION

# For a list of pre-defined annotation keys and value types see:
# https://github.com/opencontainers/image-spec/blob/master/annotations.md
# Note: Additional labels are added by the build workflow.
LABEL org.opencontainers.image.authors="mark.feldhousen@cisa.dhs.gov"
LABEL org.opencontainers.image.vendor="Cybersecurity and Infrastructure Security Agency"

ARG CISA_UID=421
ARG CISA_GID=${CISA_UID}
ENV CISA_USER="cisa"
ENV CISA_GROUP=${CISA_USER}
ENV CISA_HOME="/home/${CISA_USER}"
ENV ECHO_MESSAGE="Hello World from Dockerfile"

RUN addgroup --system --gid ${CISA_UID} cisa \
  && adduser --system --uid ${CISA_UID} --ingroup ${CISA_GROUP} ${CISA_USER}

RUN apk --update --no-cache add \
  ca-certificates=20220614-r0 \
  openssl=1.1.1q-r0

USER ${CISA_USER}
WORKDIR ${CISA_HOME}

ENV VIRTUAL_ENV="${CISA_HOME}/.venv"

RUN python3 -m venv ${VIRTUAL_ENV}
ENV PATH="${VIRTUAL_ENV}/bin:$PATH"

RUN python3 -m pip install --no-cache-dir --upgrade \
  pip==22.2.2 \
  setuptools==65.3.0 \
  wheel==0.37.1

RUN wget -O sourcecode.tgz https://github.com/cisagov/skeleton-python-library/archive/v${VERSION}.tar.gz \
  && tar xzf sourcecode.tgz --strip-components=1 \
  && python3 -m pip install --no-cache-dir --requirement requirements.txt \
  && ln -snf /run/secrets/quote.txt src/example/data/secret.txt \
  && rm sourcecode.tgz

EXPOSE 8080/TCP
VOLUME ["/var/log"]
ENTRYPOINT ["example"]
CMD ["--log-level", "DEBUG"]
