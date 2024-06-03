"""Declare runtime dependencies

These are needed for local dev, and users must install them as well.
See https://docs.bazel.build/versions/main/skylark/deploying.html#dependencies
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", _http_archive = "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def http_archive(name, **kwargs):
    maybe(_http_archive, name = name, **kwargs)

def bazel_toolchains_yocto_dependencies():
    http_archive(
        name = "bazel_skylib",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.7.1/bazel-skylib-1.7.1.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.7.1/bazel-skylib-1.7.1.tar.gz",
        ],
        sha256 = "bc283cdfcd526a52c3201279cda4bc298652efa898b10b4db0837dc51652756f",
    )
