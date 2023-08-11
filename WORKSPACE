workspace(
    name = "bazel-toolchains-yocto",
)

load(":internal_deps.bzl", "bazel_toolchains_yocto_internal_deps")

# Fetch deps needed only locally for development
bazel_toolchains_yocto_internal_deps()

load("//yocto:repositories.bzl", "bazel_toolchains_yocto_dependencies")

# Stardocs dependencies
load("@io_bazel_stardoc//:setup.bzl", "stardoc_repositories")

stardoc_repositories()

load("@rules_jvm_external//:repositories.bzl", "rules_jvm_external_deps")

rules_jvm_external_deps()

load("@rules_jvm_external//:setup.bzl", "rules_jvm_external_setup")

rules_jvm_external_setup()

load("@io_bazel_stardoc//:deps.bzl", "stardoc_external_deps")

stardoc_external_deps()

load("@stardoc_maven//:defs.bzl", stardoc_pinned_maven_install = "pinned_maven_install")

stardoc_pinned_maven_install()

bazel_toolchains_yocto_dependencies()

# For running unit tests
load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()
