#!/usr/bin/env bash
set -x

# outputs
output_dir="s3.bcf-stemcell-ubuntu-version"
mkdir -p ${output_dir}

BASE_IMAGE_VERSION_SHORT=`cat s3.bcf-base-image-ubuntu-version/bcf-base-image-ubuntu-${UBUNTU_REL}-version`

pushd git.fissile-stemcell-ubuntu
    GIT_COMMIT_STEMCELL=${GIT_COMMIT_STEMCELL:-$(git log --format="%H" -n 1)}
    GIT_COMMIT_STEMCELL_SHORT=${GIT_COMMIT_STEMCELL:0:7}
popd

STEMCELL_VERSION=${BASE_IMAGE_VERSION_SHORT}-${GIT_COMMIT_STEMCELL_SHORT}

# Check if the given stemcell image with specific tag already exists
set -e
JQ_VERSION="1.5"
curl -L "https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64" -o /usr/local/bin/jq
chmod a+x /usr/local/bin/jq
TOKEN=$( curl -sSLd "username=${DOCKER_USER}&password=${DOCKER_PASS}" https://hub.docker.com/v2/users/login | jq -r ".token" )
set +e
curl -sHk "https://hub.docker.com/v2/repositories/${DOCKER_REPO}/tags/${STEMCELL_VERSION}/" | grep "Not found"

if [ $? -ne 0 ]; then
    echo "The bcf-stemcell with tag ${STEMCELL_VERSION} already exists, ignore image creation."
    exit 1
else
    echo "The bcf-stemcell with tag ${STEMCELL_VERSION} does not exist, generate the version for subsequent image creation."
    echo "${STEMCELL_VERSION}" > s3.bcf-stemcell-ubuntu-version/bcf-stemcell-ubuntu-${UBUNTU_REL}-version
fi