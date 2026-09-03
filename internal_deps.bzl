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
        sha256 = "accf9c9da9382dac3f7416134672a60dba0238f64dee8f0674dcc046098c4006",
        strip_prefix = "bazel-lib-3.7.2",
        url = "https://github.com/aspect-build/bazel-lib/archive/refs/tags/v3.7.2.tar.gz",
    )
