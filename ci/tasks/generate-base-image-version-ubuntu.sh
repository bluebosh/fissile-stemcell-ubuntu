#!/usr/bin/env bash
set -x

# outputs
output_dir="s3.bcf-base-image-ubuntu-version"
mkdir -p ${output_dir}

BASE_IMAGE_VERSION=`cat git.bosh-linux-stemcell-builder/bosh-stemcell/ubuntu-${UBUNTU_REL}.meta4 | grep -o -P '(?<=versionId=).*(?=\/url>)'`
BASE_IMAGE_VERSION_SHORT=${BASE_IMAGE_VERSION:1:7}

# Check if the given base image with specific tag already exists
TOKEN=$( curl -sSLd "username=${DOCKER_USER}&password=${DOCKER_PASS}" https://hub.docker.com/v2/users/login | jq -r ".token" )
curl -sH "Authorization: JWT $TOKEN" "https://hub.docker.com/v2/repositories/${DOCKER_REPO}/tags/${BASE_IMAGE_VERSION_SHORT}/" | grep "Not found"
if [ $? -ne 0 ]; then
    echo "The base-image with tag ${BASE_IMAGE_VERSION_SHORT} already exists, ignore image creation."
    exit 1
else
    echo "The base-image with tag ${BASE_IMAGE_VERSION_SHORT} does not exist, generate the version for subsequent image creation."
    echo "${BASE_IMAGE_VERSION_SHORT}" > s3.bcf-base-image-ubuntu-version/bcf-base-image-ubuntu-${UBUNTU_REL}-version
fi