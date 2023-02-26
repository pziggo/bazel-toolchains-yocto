workspace(
    name = "bazel-toolchains-yocto",
)

load(":internal_deps.bzl", "bazel_toolchains_yocto_internal_deps")

# Fetch deps needed only locally for development
bazel_toolchains_yocto_internal_deps()

load("//yocto:repositories.bzl", "bazel_toolchains_yocto_dependencies")

bazel_toolchains_yocto_dependencies()

# For running unit tests
load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()
