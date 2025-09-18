"""Test configuration for local SDK"""

load("//yocto:defs.bzl", "local_yocto_toolchain")

def setup_test_sdk():
    local_yocto_toolchain(
        name = "yocto_aarch64",
    )
