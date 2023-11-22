"""Internal dependencies required during development of the rule."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", _http_archive = "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def http_archive(name, **kwargs):
    maybe(_http_archive, name = name, **kwargs)

def bazel_toolchains_yocto_internal_deps():
    http_archive(
        name = "io_bazel_stardoc",
        sha256 = "62bd2e60216b7a6fec3ac79341aa201e0956477e7c8f6ccc286f279ad1d96432",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/stardoc/releases/download/0.6.2/stardoc-0.6.2.tar.gz",
            "https://github.com/bazelbuild/stardoc/releases/download/0.6.2/stardoc-0.6.2.tar.gz",
        ],
    )

    http_archive(
        name = "aspect_bazel_lib",
        sha256 = "7489849cffe8d5cf3e6326f5156e7984c7cf6a75a3a0873a5e9b24f4144ab931",
        strip_prefix = "bazel-lib-1.39.0",
        url = "https://github.com/aspect-build/bazel-lib/archive/refs/tags/v1.39.0.tar.gz",
    )
