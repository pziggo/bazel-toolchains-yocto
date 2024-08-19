"""Internal dependencies required during development of the rule."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", _http_archive = "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def http_archive(name, **kwargs):
    maybe(_http_archive, name = name, **kwargs)

def bazel_toolchains_yocto_internal_deps():
    http_archive(
        name = "io_bazel_stardoc",
        sha256 = "dd7f32f4fe2537ce2452c51f816a5962d48888a5b07de2c195f3b3da86c545d3",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/stardoc/releases/download/0.7.0/stardoc-0.7.0.tar.gz",
            "https://github.com/bazelbuild/stardoc/releases/download/0.7.0/stardoc-0.7.0.tar.gz",
        ],
    )

    http_archive(
        name = "aspect_bazel_lib",
        sha256 = "d96f4dc5c129a033e6851a03b04219513bd32aed66f13f93d87879e3cb0349db",
        strip_prefix = "bazel-lib-2.8.1",
        url = "https://github.com/aspect-build/bazel-lib/archive/refs/tags/v2.8.1.tar.gz",
    )
