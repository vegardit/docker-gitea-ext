# Copyright 2019-2020 by Vegard IT GmbH, Germany, https://vegardit.com
# SPDX-License-Identifier: Apache-2.0
#
# @author Sebastian Thomschke, Vegard IT GmbH
#
# https://github.com/vegardit/docker-gitea-ext
#

FROM gitea/gitea:1

LABEL \
  maintainer="Vegard IT GmbH (vegardit.com)" \
  org.label-schema.vcs-url="https://github.com/vegardit/docker-gitea-ext.git"

RUN \
  set -x && \
  ############################################################
  echo "Installing latest OS updates..." && \
  apk -U upgrade && \
  ############################################################
  echo "Installing asciidoctor..." && \
  apk --no-cache add asciidoctor && \
  echo -e '\n\
[markup.asciidoc]\n\
ENABLED = true\n\
RENDER_COMMAND = "asciidoctor -e -a leveloffset=-1 --out-file=- -"\n\
' >> /etc/templates/app.ini
