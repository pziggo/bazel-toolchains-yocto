workspace(
    name = "bazel-toolchains-yocto",
)

load(":internal_deps.bzl", "bazel_toolchains_yocto_internal_deps")

# Fetch deps needed only locally for development
bazel_toolchains_yocto_internal_deps()

load("//toolchains:repositories.bzl", "bazel_toolchains_yocto_dependencies")

bazel_toolchains_yocto_dependencies()
