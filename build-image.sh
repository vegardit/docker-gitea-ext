#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: © Vegard IT GmbH (https://vegardit.com)
# SPDX-FileContributor: Sebastian Thomschke
# SPDX-License-Identifier: Apache-2.0
# SPDX-ArtifactOfProjectHomePage: https://github.com/vegardit/docker-gitea-ext
#

shared_lib="$(dirname $0)/.shared"
[ -e "$shared_lib" ] || curl -sSf https://raw.githubusercontent.com/vegardit/docker-shared/v1/download.sh?_=$(date +%s) | bash -s v1 "$shared_lib" || exit 1
source "$shared_lib/lib/build-image-init.sh"


#################################################
# specify target docker registry/repo
#################################################
docker_registry=${DOCKER_REGISTRY:-docker.io}
image_repo=${DOCKER_IMAGE_REPO:-vegardit/gitea-ext}
image_name=$image_repo:${DOCKER_IMAGE_TAG:-latest}


#################################################
# build the image
#################################################
echo "Building docker image [$image_name]..."
if [[ $OSTYPE == "cygwin" || $OSTYPE == "msys" ]]; then
   project_root=$(cygpath -w "$project_root")
fi

DOCKER_BUILDKIT=1 docker build "$project_root" \
   --file "image/Dockerfile" \
   --progress=plain \
   --pull \
   `# using the current date as value for BASE_LAYER_CACHE_KEY, i.e. the base layer cache (that holds system packages with security updates) will be invalidate once per day` \
   --build-arg BASE_LAYER_CACHE_KEY=$base_layer_cache_key \
   --build-arg BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
   --build-arg GIT_BRANCH="${GIT_BRANCH:-$(git rev-parse --abbrev-ref HEAD)}" \
   --build-arg GIT_COMMIT_DATE="$(date -d @$(git log -1 --format='%at') --utc +'%Y-%m-%d %H:%M:%S UTC')" \
   --build-arg GIT_COMMIT_HASH="$(git rev-parse --short HEAD)" \
   --build-arg GIT_REPO_URL="$(git config --get remote.origin.url)" \
   -t $image_name \
   "$@"


#################################################
# determine effective version and apply tags
#################################################
# LC_ALL=en_US.utf8 -> workaround for "grep: -P supports only unibyte and UTF-8 locales"
# 2>/dev/null -> workaround for "write /dev/stdout: The pipe is being closed."
gitea_version=$(docker run --rm $image_name /app/gitea/gitea --version | LC_ALL=en_US.utf8 grep -oP 'Gitea version \K\d+\.\d+\.\d+' || true)
echo gitea_version=$gitea_version
docker image tag $image_name $image_repo:${gitea_version%.*}.x  #1.12.x
docker image tag $image_name $image_repo:${gitea_version%%.*}.x #1.x


#################################################
# perform security audit
#################################################
if [[ "${DOCKER_AUDIT_IMAGE:-1}" == 1 ]]; then
   bash "$shared_lib/cmd/audit-image.sh" $image_name
fi


#################################################
# push image with tags to remote docker image registry
#################################################
if [[ "${DOCKER_PUSH:-0}" == "1" ]]; then
   docker image tag $image_name $docker_registry/$image_name
   #docker image tag $image_name $docker_registry/$image_repo:${gitea_version}      #1.12.4
   #docker image tag $image_name $docker_registry/$image_repo:${gitea_version%.*}.x #1.12.x
   docker image tag $image_name $docker_registry/$image_repo:${gitea_version%%.*}.x #1.x

   docker push $docker_registry/$image_name
   #docker push $docker_registry/$image_repo:${gitea_version}       #1.12.4
   #docker push $docker_registry/$image_repo:${gitea_version%.*}.x  #1.12.x
   docker push $docker_registry/$image_repo:${gitea_version%%.*}.x #1.x
fi
