"""This module provides the definitions for configuring a Yocto toolchain for C and C++.
"""

load(
    "//toolchains/private:sdk.bzl",
    _yocto_download_sdk = "yocto_download_sdk",
)

yocto_download_sdk = _yocto_download_sdk
