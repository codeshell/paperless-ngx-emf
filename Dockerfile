ARG PATCH_IMAGETAG=3.3.3

FROM ghcr.io/paperless-ngx/paperless-ngx:${PATCH_IMAGETAG} AS patcher
# The upstream is currently based on debian (ghcr.io/astral-sh/uv:0.12.23-python3.14-trixie-slim)
# The upstream WORKDIR is /usr/src/paperless/src/

ARG PATCH_IMAGETAG
ARG PATCH_PACKAGES="patch"
ARG PATCH_TARGET_DIR="/usr/src/paperless"
ARG PATCH_FILE="/tmp/mail-metadata.diff"

RUN set -eux \
    && echo "Installing additional dependencies" \
      && apt-get update \
      && DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet --no-install-recommends \
        ${PATCH_PACKAGES} \
    && echo "Download patch file" \
      && curl --fail --silent --no-progress-meter --show-error --location \
        --output "${PATCH_FILE}" \
        "https://github.com/paperless-ngx/paperless-ngx/compare/v${PATCH_IMAGETAG}...robin-moser:paperless-ngx:feature-mail-metadata-custom-fields.diff" \
    && echo "Apply patch to target file: /usr/src/paperless/src/paperless_mail/mail.py" \
      && patch -d "${PATCH_TARGET_DIR}" -p1 < "${PATCH_FILE}" \
    && echo "Cleaning up image" \
      && rm "${PATCH_FILE}" \
      && apt-get --yes purge ${PATCH_PACKAGES} \
      && apt-get --yes autoremove --purge \
      && apt-get clean --yes \
      && rm -rf /var/lib/apt/lists/* \
    && echo "FINIS"

FROM ghcr.io/paperless-ngx/paperless-ngx:${PATCH_IMAGETAG} AS paperless-ngx
COPY --from=patcher \
    /usr/src/paperless/src/paperless_mail/mail.py \
    /usr/src/paperless/src/paperless_mail/mail.py
