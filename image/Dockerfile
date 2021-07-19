#syntax=docker/dockerfile:1.2
# Copyright 2020-2021 by Vegard IT GmbH, Germany, https://vegardit.com
# SPDX-License-Identifier: Apache-2.0
#
# Author: Sebastian Thomschke, Vegard IT GmbH
#
# https://github.com/vegardit/docker-gitea-ext
#

# https://github.com/go-gitea/gitea/blob/main/Dockerfile
FROM gitea/gitea:1

LABEL maintainer="Vegard IT GmbH (vegardit.com)"

USER root

SHELL ["/bin/bash", "-c"]

ARG BASE_LAYER_CACHE_KEY

RUN --mount=type=bind,source=.shared,target=/mnt/shared \
  set -eu && \
  /mnt/shared/cmd/alpine-install-os-updates.sh && \
  #
  echo "#################################################" &&\
  echo "Installing asciidoctor..." &&\
  echo "#################################################" && \
  apk --no-cache add asciidoctor && \
  echo -e '\n\
[markup.asciidoc]\n\
ENABLED = true\n\
RENDER_COMMAND = "asciidoctor -e -a leveloffset=-1 --out-file=- -"\n\
' >>/etc/templates/app.ini && \
  #
  /mnt/shared/cmd/alpine-cleanup.sh

ARG BUILD_DATE
ARG GIT_COMMIT_HASH
ARG GIT_REPO_URL

LABEL \
 org.label-schema.schema-version="1.0" \
 org.label-schema.build-date=$BUILD_DATE \
 org.label-schema.vcs-ref=$GIT_COMMIT_HASH \
 org.label-schema.vcs-url=$GIT_REPO_URL
