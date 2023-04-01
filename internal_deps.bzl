"""Internal dependencies required during development of the rule."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", _http_archive = "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def http_archive(name, **kwargs):
    maybe(_http_archive, name = name, **kwargs)

def bazel_toolchains_yocto_internal_deps():
    http_archive(
        name = "io_bazel_stardoc",
        sha256 = "3fd8fec4ddec3c670bd810904e2e33170bedfe12f90adf943508184be458c8bb",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/stardoc/releases/download/0.5.3/stardoc-0.5.3.tar.gz",
            "https://github.com/bazelbuild/stardoc/releases/download/0.5.3/stardoc-0.5.3.tar.gz",
        ],
    )

    http_archive(
        name = "aspect_bazel_lib",
        sha256 = "965c64e7eed12b208fb49cd731d8c0dae2b3b3a64917437c899a0f5c5f292dcc",
        strip_prefix = "bazel-lib-1.30.1",
        url = "https://github.com/aspect-build/bazel-lib/archive/refs/tags/v1.30.1.tar.gz",
    )
