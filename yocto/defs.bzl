"""Macros for downloading yocto toolchains"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")
load("//yocto/private:sdk_utils.bzl", "install_and_setup_sdk", "link_and_setup_sdk")

def http_yocto_toolchain_archive(
        name,
        environment_setup,
        sdk_installer,
        build_file = None,
        build_file_content = "",
        **kwargs):
    """Download archived toolchain script

    Args:
        name (str): Name of the final toolchain repository
        build_file (label, optional): The file to use as the BUILD file for the SDK tree.
        build_file_content (label, optional): The content for the BUILD file for the SDK tree.
        environment_setup (str): Name of the environment setup file
        sdk_installer (str): Name of the self extracting toolchain script
        **kwargs (dict): Keyword arguments for the `http_archive`, see https://bazel.build/rules/lib/repo/http#http_archive.
    """
    http_archive(
        name = "{}_dl".format(name),
        build_file_content = 'export_files(glob(["**"]))',
        **kwargs
    )

    install_and_setup_sdk(
        name = name,
        build_file = build_file,
        build_file_content = build_file_content,
        environment_setup = environment_setup,
        # Labels will not be resolved to the end in repository rules ... files must be named as they are
        sdk_installer = "@{}_dl//:{}".format(name, sdk_installer),
    )

def http_yocto_toolchain_file(
        name,
        environment_setup,
        build_file = None,
        build_file_content = "",
        **kwargs):
    """Download self extracting toolchain script

    Args:
        name (str): Name of the final toolchain repository
        build_file (label, optional): The file to use as the BUILD file for the SDK tree.
        build_file_content (label, optional): The content for the BUILD file for the SDK tree.
        environment_setup (str): Name of the environment setup file
        **kwargs (dict): Keyword arguments for the `http_file`, see https://bazel.build/rules/lib/repo/http#http_file.
    """
    http_file(
        name = "{}_dl".format(name),
        **kwargs
    )

    install_and_setup_sdk(
        name = name,
        build_file = build_file,
        build_file_content = build_file_content,
        environment_setup = environment_setup,
        # Labels will not be resolved to the end in repository rules ... files must be named as they are
        sdk_installer = "@{}_dl//file:downloaded".format(name),
    )

def local_yocto_toolchain(
        name,
        build_file = None,
        build_file_content = ""):
    """Using local installed toolchain

    Args:
        name (str): Name of the final toolchain repository
        build_file (label, optional): The file to use as the BUILD file for the SDK tree.
        build_file_content (label, optional): The content for the BUILD file for the SDK tree.
    """
    link_and_setup_sdk(
        name = name,
        build_file = build_file,
        build_file_content = build_file_content,
    )
