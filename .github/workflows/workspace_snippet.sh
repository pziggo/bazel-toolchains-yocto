#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

# Set by GH actions, see
# https://docs.github.com/en/actions/learn-github-actions/environment-variables#default-environment-variables
TAG=${GITHUB_REF_NAME}
PREFIX="bazel-toolchains-yocto-${TAG:1}"
SHA=$(git archive --format=tar --prefix=${PREFIX}/ ${TAG} | gzip | shasum -a 256 | awk '{print $1}')

cat << EOF
WORKSPACE snippet:
\`\`\`starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
http_archive(
    name = "bazel_toolchains_yocto",
    sha256 = "${SHA}",
    strip_prefix = "${PREFIX}",
    url = "https://github.com/pziggo/bazel-toolchains-yocto/archive/refs/tags/${TAG}.tar.gz",
)

load("@bazel_toolchains_yocto//yocto:repositories.bzl", "bazel_toolchains_yocto_dependencies")

bazel_toolchains_yocto_dependencies()
\`\`\`
EOF
