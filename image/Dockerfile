#syntax=docker/dockerfile:1
#
# SPDX-FileCopyrightText: © Vegard IT GmbH (https://vegardit.com)
# SPDX-FileContributor: Sebastian Thomschke
# SPDX-License-Identifier: Apache-2.0
# SPDX-ArtifactOfProjectHomePage: https://github.com/vegardit/docker-gitea-ext
#

# https://github.com/go-gitea/gitea/blob/main/Dockerfile
FROM gitea/gitea:1

LABEL maintainer="Vegard IT GmbH (vegardit.com)"

# https://github.com/hadolint/hadolint/wiki/DL3002 Last USER should not be root
# hadolint ignore=DL3002
USER root

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

ARG BASE_LAYER_CACHE_KEY

# https://github.com/hadolint/hadolint/wiki/DL3018 Pin versions
# hadolint ignore=DL3018
RUN --mount=type=bind,source=.shared,target=/mnt/shared <<EOF
  /mnt/shared/cmd/alpine-install-os-updates.sh

  echo "#################################################"
  echo "Installing asciidoctor..."
  echo "#################################################"
  apk --no-cache add asciidoctor
  echo -e '\n\
[markup.asciidoc]\n\
ENABLED = true\n\
RENDER_COMMAND = "asciidoctor -e -a leveloffset=-1 --out-file=- -"\n\
' >>/etc/templates/app.ini

  /mnt/shared/cmd/alpine-cleanup.sh

EOF

ARG BUILD_DATE
ARG GIT_COMMIT_HASH
ARG GIT_REPO_URL

# https://github.com/opencontainers/image-spec/blob/main/annotations.md
LABEL \
  org.opencontainers.image.source=$GIT_REPO_URL \
  org.opencontainers.image.created=$BUILD_DATE \
  org.opencontainers.image.revision=$GIT_COMMIT_HASH \
  org.opencontainers.image.vision=$GIT_COMMIT_HASH
