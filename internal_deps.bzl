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
        sha256 = "04b9b165d90afeffc7e3ba5fdcee0b233dfa9a4602ce068072f662206c4f36c3",
        strip_prefix = "bazel-lib-2.22.5",
        url = "https://github.com/aspect-build/bazel-lib/archive/refs/tags/v2.22.5.tar.gz",
    )
