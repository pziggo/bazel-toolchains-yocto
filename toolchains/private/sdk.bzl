"""This module provides the implementation for configuring a Yocto toolchain for C and C++.
"""

load("@bazel_skylib//lib:paths.bzl", "paths")

def _sdk_download(ctx):
    installer = ""

    if ctx.attr.urls[0].endswith(".sh"):
        # Default yocto installer script
        installer = paths.basename(ctx.attr.urls[0])
        ctx.download(
            url = ctx.attr.urls,
            output = installer,
            sha256 = ctx.attr.sha256,
        )
    elif not ctx.attr.installer:
        fail("Attribute installer is mandatory if URL points to an archive.")
    else:
        # Assume the installer script was archived again
        installer = ctx.attr.installer
        ctx.download_and_extract(
            url = ctx.attr.urls,
            sha256 = ctx.attr.sha256,
            stripPrefix = ctx.attr.strip_prefix,
        )

    ctx.report_progress("Extracting Yocto toolchain {}".format(installer))
    res = ctx.execute(["sh", installer, "-y", "-d", ctx.path("."), "-R"])
    if res.return_code:
        fail("error extracting Yocto SDK:\n" + res.stdout + res.stderr)

def _get_env_pair(line):
    k, _, v = line.partition("=")
    return {k: v.strip("\"").split(" ")}

def _unique(iterable):
    """Remove duplicates from a list."""
    elements = []
    for element in iterable:
        if element not in elements:
            elements.append(element)
    return elements

def _format_flags(iterable):
    """Format flags and remove empty elements."""
    return _unique([element for element in iterable if element])

def _replace_in_flags(iterable, old, new):
    """Replace string in all occurences of the given flags."""
    elements = []
    for element in iterable:
        elements.append(element.replace(old, new))
    return elements

def _sdk_environment_setup(ctx):
    env = dict()

    identifier = ctx.attr.identifier if ctx.attr.identifier else ctx.name

    ctx.report_progress("Parsing environment-setup-{}".format(identifier))
    contents = ctx.read("environment-setup-{}".format(identifier))

    lines = contents.splitlines()

    prefix = "export "
    for line in lines:
        if line.startswith(prefix):
            env.update(_get_env_pair(line.removeprefix(prefix)))

    return env

def _sdk_generate_config(ctx, env):
    ctx.report_progress("Generate toolchain configuration")
    repo_root = str(ctx.path("."))
    native_sysroot = paths.relativize(env.get("OECORE_NATIVE_SYSROOT")[0], repo_root)
    native_prefix = paths.basename(env.get("OECORE_NATIVE_SYSROOT")[0])
    target_arch = env.get("OECORE_TARGET_ARCH")[0]
    target_os = env.get("OECORE_TARGET_OS")[0]
    target_sysroot = paths.relativize(env.get("SDKTARGETSYSROOT")[0], repo_root)
    target_prefix = env.get("TARGET_PREFIX")[0].removesuffix("-")
    cxx_builtin_include_directories = []
    compile_flags = _format_flags(env.get("CC")[1:])
    dbg_compile_flags = []
    opt_compile_flags = []
    link_flags = _format_flags(env.get("LD")[1:])
    archive_flags = []
    link_libs = ["-lstdc++", "-lm"]
    opt_link_flags = []
    builtin_sysroot = ""

    compile_flags.extend(_format_flags(env.get("CFLAGS")))
    link_flags.extend(_format_flags(env.get("LDFLAGS")))

    # only add flags if not in compile_flags
    cxx_flags = [flag for flag in _format_flags(env.get("CXX")[1:]) if flag not in compile_flags]
    cxx_flags.extend([flag for flag in _format_flags(env.get("CXXFLAGS")) if flag not in compile_flags])

    compile_flags = _replace_in_flags(compile_flags, "$SDKTARGETSYSROOT", "external/{}/{}".format(ctx.attr.name, target_sysroot))
    link_flags = _replace_in_flags(link_flags, "$SDKTARGETSYSROOT", "external/{}/{}".format(ctx.attr.name, target_sysroot))

    tool_paths = {
        "addr2line": "/bin/false",
        "ar": "{}-ar".format(target_prefix),
        "as": "{}-as".format(target_prefix),
        "compat-ld": "/bin/false",
        "cpp": "{}-cpp".format(target_prefix),
        "dwp": "/bin/false",
        "gcc": "{}-gcc".format(target_prefix),
        "gcov": "/bin/false",
        "ld": "{}-ld".format(target_prefix),
        "nm": "{}-nm".format(target_prefix),
        "objcopy": "{}-objcopy".format(target_prefix),
        "objdump": "{}-objdump".format(target_prefix),
        "strip": "{}-strip".format(target_prefix),
    }

    ctx.template(
        "BUILD.bazel",
        Label("//toolchains/private:templates/BUILD.tpl"),
        executable = False,
        substitutions = {
            "{native_sysroot}": native_sysroot,
            "{target_sysroot}": target_sysroot,
            "{target_prefix}": target_prefix,
        },
    )

    ctx.template(
        "toolchain/BUILD.bazel",
        Label("//toolchains/private:templates/toolchain_BUILD.tpl"),
        executable = False,
        substitutions = {
            "{target_arch}": target_arch,
            "{target_os}": target_os,
            "{target_prefix}": target_prefix,
            "{name}": ctx.attr.name,
            "{native_prefix}": native_prefix,
            "{cxx_builtin_include_directories}": str(cxx_builtin_include_directories),
            "{tool_paths}": str(tool_paths),
            "{compile_flags}": str(compile_flags),
            "{dbg_compile_flags}": str(dbg_compile_flags),
            "{opt_compile_flags}": str(opt_compile_flags),
            "{cxx_flags}": str(cxx_flags),
            "{link_flags}": str(link_flags),
            "{archive_flags}": str(archive_flags),
            "{link_libs}": str(link_libs),
            "{opt_link_flags}": str(opt_link_flags),
            "{builtin_sysroot}": builtin_sysroot,
        },
    )

    ctx.template(
        "toolchain/cc_config.bzl",
        Label("//toolchains/private:templates/toolchain_cc_config.tpl"),
        executable = False,
    )

    ctx.template(
        "toolchain/ld-linux-x86-64.so.2",
        Label("//toolchains/private:wrappers/ld_wrapper"),
        executable = True,
        substitutions = {
            "{native_sysroot}": "external/{}/{}".format(ctx.attr.name, native_sysroot),
        },
    )

    for tool in ["cpp", "gcc"]:
        ctx.template(
            "toolchain/{}-{}".format(target_prefix, tool),
            Label("//toolchains/private:wrappers/compiler_wrapper"),
            executable = True,
            substitutions = {
                "{native_sysroot}": "external/{}/{}".format(ctx.attr.name, native_sysroot),
                "{target_prefix}": target_prefix,
            },
        )

    for tool in ["ar", "as", "ld", "nm", "objcopy", "objdump", "strip"]:
        ctx.template(
            "toolchain/{}-{}".format(target_prefix, tool),
            Label("//toolchains/private:wrappers/generic_wrapper"),
            executable = True,
            substitutions = {
                "{native_sysroot}": "external/{}/{}".format(ctx.attr.name, native_sysroot),
                "{target_prefix}": target_prefix,
            },
        )

def _yocto_download_sdk_impl(ctx):
    _sdk_download(ctx)
    env = _sdk_environment_setup(ctx)
    _sdk_generate_config(ctx, env)

yocto_download_sdk = repository_rule(
    implementation = _yocto_download_sdk_impl,
    attrs = {
        "urls": attr.string_list(
            mandatory = True,
            doc = """A list of URLs to a Yocto toolchain.

The toolchain must be in the format of a self extracting shell script with the
`.sh` file extension (Yocto standard) as a single file or within an archive.
Each entry must be a file, http or https URL. Redirections are followed.
URLs are tried in order until one succeeds, so you should list local mirrors first.
If all downloads fail, the rule will fail.""",
        ),
        "sha256": attr.string(
            mandatory = True,
            doc = """The expected SHA-256 of the file downloaded.

This must match the SHA-256 of the file downloaded. _It is a security risk
to omit the SHA-256 as remote files can change._ At best omitting this
field will make your build non-hermetic. It is optional to make development
easier this attribute should be set before shipping.""",
        ),
        "identifier": attr.string(
            mandatory = False,
            doc = "Identifier for the target system to match the environment-setup file suffix",
        ),
        "installer": attr.string(
            mandatory = False,
            doc = "Basename of the SDK installer script inside an archive.",
        ),
        "strip_prefix": attr.string(
            mandatory = False,
            doc = "Strip directory while extracting the archive.",
        ),
    },
    environ = [
        "CC",
        "CFLAGS",
        "CXX",
        "CXXFLAGS",
        "LDFLAGS",
        "OECORE_NATIVE_SYSROOT",
        "OECORE_TARGET_ARCH",
        "OECORE_TARGET_OS",
        "SDKTARGETSYSROOT",
        "TARGET_PREFIX",
    ],
)
