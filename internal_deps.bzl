"""Internal dependencies required during development of the rule."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", _http_archive = "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def http_archive(name, **kwargs):
    maybe(_http_archive, name = name, **kwargs)

def bazel_toolchains_yocto_internal_deps():
    http_archive(
        name = "io_bazel_stardoc",
        sha256 = "ec57139e466faae563f2fc39609da4948a479bb51b6d67aedd7d9b1b8059c433",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/stardoc/releases/download/0.5.4/stardoc-0.5.4.tar.gz",
            "https://github.com/bazelbuild/stardoc/releases/download/0.5.4/stardoc-0.5.4.tar.gz",
        ],
    )

    http_archive(
        name = "aspect_bazel_lib",
        sha256 = "5f3443b1d98a462a8b7330f4742483afc8b2d17c8555dd97ce4146f43e961718",
        strip_prefix = "bazel-lib-1.31.1",
        url = "https://github.com/aspect-build/bazel-lib/archive/refs/tags/v1.31.1.tar.gz",
    )
