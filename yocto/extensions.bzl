"""Bzlmod module extension for Yocto toolchains."""

load(
    "//yocto:defs.bzl",
    "http_yocto_toolchain_archive",
    "http_yocto_toolchain_file",
    "local_yocto_toolchain",
)

def _maybe(kwargs, key, value):
    if value == None:
        return
    if type(value) == type("") and value == "":
        return
    if type(value) == type([]) and not value:
        return
    if type(value) == type({}) and not value:
        return
    kwargs[key] = value

def _http_archive_kwargs(tag):
    kwargs = {}
    _maybe(kwargs, "url", tag.url)
    _maybe(kwargs, "urls", tag.urls)
    _maybe(kwargs, "sha256", tag.sha256)
    _maybe(kwargs, "integrity", tag.integrity)
    _maybe(kwargs, "strip_prefix", tag.strip_prefix)
    _maybe(kwargs, "patches", tag.patches)
    _maybe(kwargs, "patch_args", tag.patch_args)
    _maybe(kwargs, "patch_tool", tag.patch_tool)
    _maybe(kwargs, "patch_cmds", tag.patch_cmds)
    _maybe(kwargs, "patch_cmds_win", tag.patch_cmds_win)
    _maybe(kwargs, "repo_mapping", tag.repo_mapping)
    return kwargs

def _http_file_kwargs(tag):
    kwargs = {}
    _maybe(kwargs, "url", tag.url)
    _maybe(kwargs, "urls", tag.urls)
    _maybe(kwargs, "sha256", tag.sha256)
    _maybe(kwargs, "integrity", tag.integrity)
    _maybe(kwargs, "downloaded_file_path", tag.downloaded_file_path)
    _maybe(kwargs, "executable", tag.executable)
    _maybe(kwargs, "auth_patterns", tag.auth_patterns)
    _maybe(kwargs, "canonical_id", tag.canonical_id)
    _maybe(kwargs, "repo_mapping", tag.repo_mapping)
    return kwargs

def _yocto_toolchains_impl(module_ctx):
    for mod in module_ctx.modules:
        for tag in mod.tags.http_archive:
            http_yocto_toolchain_archive(
                name = tag.name,
                environment_setup = tag.environment_setup,
                sdk_installer = tag.sdk_installer,
                build_file = tag.build_file,
                build_file_content = tag.build_file_content,
                **_http_archive_kwargs(tag)
            )

        for tag in mod.tags.http_file:
            http_yocto_toolchain_file(
                name = tag.name,
                environment_setup = tag.environment_setup,
                build_file = tag.build_file,
                build_file_content = tag.build_file_content,
                **_http_file_kwargs(tag)
            )

        for tag in mod.tags.local:
            local_yocto_toolchain(
                name = tag.name,
                build_file = tag.build_file,
                build_file_content = tag.build_file_content,
            )

yocto_toolchains = module_extension(
    implementation = _yocto_toolchains_impl,
    tag_classes = {
        "http_archive": tag_class(
            attrs = {
                "name": attr.string(mandatory = True),
                "environment_setup": attr.string(mandatory = True),
                "sdk_installer": attr.string(mandatory = True),
                "build_file": attr.label(),
                "build_file_content": attr.string(),
                "url": attr.string(),
                "urls": attr.string_list(),
                "sha256": attr.string(),
                "integrity": attr.string(),
                "strip_prefix": attr.string(),
                "patches": attr.label_list(),
                "patch_args": attr.string_list(),
                "patch_tool": attr.string(),
                "patch_cmds": attr.string_list(),
                "patch_cmds_win": attr.string_list(),
                "repo_mapping": attr.string_dict(),
            },
        ),
        "http_file": tag_class(
            attrs = {
                "name": attr.string(mandatory = True),
                "environment_setup": attr.string(mandatory = True),
                "build_file": attr.label(),
                "build_file_content": attr.string(),
                "url": attr.string(),
                "urls": attr.string_list(),
                "sha256": attr.string(),
                "integrity": attr.string(),
                "downloaded_file_path": attr.string(),
                "executable": attr.bool(),
                "auth_patterns": attr.string_dict(),
                "canonical_id": attr.string(),
                "repo_mapping": attr.string_dict(),
            },
        ),
        "local": tag_class(
            attrs = {
                "name": attr.string(mandatory = True),
                "build_file": attr.label(),
                "build_file_content": attr.string(),
            },
        ),
    },
)
