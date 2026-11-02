"""Internal dependencies required during development of the rule."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", _http_archive = "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def http_archive(name, **kwargs):
    maybe(_http_archive, name = name, **kwargs)

def bazel_toolchains_yocto_internal_deps():
    http_archive(
        name = "io_bazel_stardoc",
        sha256 = "ab6b747b3164510547f7696c6e06921966ccec7e08d9b81ec60133c3b09d5e5e",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/stardoc/releases/download/0.8.1/stardoc-0.8.1.tar.gz",
            "https://github.com/bazelbuild/stardoc/releases/download/0.8.1/stardoc-0.8.1.tar.gz",
        ],
    )

    http_archive(
        name = "aspect_bazel_lib",
        sha256 = "64021c804cc383af03d87be142b514f944e2e015b1d834c624a23f461fc210f8",
        strip_prefix = "bazel-lib-3.8.0",
        url = "https://github.com/aspect-build/bazel-lib/archive/refs/tags/v3.8.0.tar.gz",
    )
