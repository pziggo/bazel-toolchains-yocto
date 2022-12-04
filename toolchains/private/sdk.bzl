"""This module provides the implementation for configuring a Yocto toolchain for C and C++.
"""

load("@bazel_skylib//lib:paths.bzl", "paths")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "read_netrc", "read_user_netrc", "use_netrc")

def _get_auth(ctx):
    """Given the list of URLs obtain the correct auth dict."""
    if ctx.attr.netrc:
        netrc = read_netrc(ctx, ctx.attr.netrc)
    else:
        netrc = read_user_netrc(ctx)
    return use_netrc(netrc, ctx.attr.urls, ctx.attr.auth_patterns)

def _sdk_download(ctx):
    installer = ""
    auth = _get_auth(ctx)

    if ctx.attr.urls[0].endswith(".sh"):
        # Default yocto installer script
        installer = paths.basename(ctx.attr.urls[0])
        ctx.download(
            url = ctx.attr.urls,
            output = installer,
            sha256 = ctx.attr.sha256,
            auth = auth,
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
            auth = auth,
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

    res = ctx.execute([ctx.path(ctx.attr._post_script), target_sysroot])
    if res.return_code:
        fail("error post patching Yocto SDK:\n" + res.stdout + res.stderr)

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

    if ctx.attr.build_file:
        ctx.file("BUILD.bazel", ctx.read(ctx.attr.build_file))
    else:
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
            "{bazel_toolchains_yocto_workspace_name}": ctx.attr.bazel_toolchains_yocto_workspace_name,
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

    ctx.template(
        "toolchain/as",
        Label("//toolchains/private:wrappers/as_wrapper"),
        executable = True,
        substitutions = {
            "{native_sysroot}": "external/{}/{}".format(ctx.attr.name, native_sysroot),
            "{target_prefix}": target_prefix,
        },
    )

    ctx.template(
        "toolchain/real-ld",
        Label("//toolchains/private:wrappers/real-ld"),
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

def _yocto_local_sdk_impl(ctx):
    _sdk_generate_config(ctx, ctx.os.environ)

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
        "netrc": attr.string(
            doc = "Location of the .netrc file to use for authentication",
        ),
        "auth_patterns": attr.string_dict(
            doc = """An optional dict mapping host names to custom authorization patterns.

If a URL's host name is present in this dict the value will be used as a pattern when
generating the authorization header for the http request. This enables the use of custom
authorization schemes used in a lot of common cloud storage providers.
The pattern currently supports 2 tokens: <code>&lt;login&gt;</code> and
<code>&lt;password&gt;</code>, which are replaced with their equivalent value
in the netrc file for the same host name. After formatting, the result is set
as the value for the <code>Authorization</code> field of the HTTP request.
Example attribute and netrc for a http download to an oauth2 enabled API using a bearer token:
<pre>
auth_patterns = {
    "storage.cloudprovider.com": "Bearer &lt;password&gt;"
}
</pre>
netrc:
<pre>
machine storage.cloudprovider.com
        password RANDOM-TOKEN
</pre>
The final HTTP request would have the following header:
<pre>
Authorization: Bearer RANDOM-TOKEN
</pre>
""",
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
        "build_file": attr.label(
            allow_single_file = True,
            doc = """
The file to use as the BUILD file for the toolchain repository.
The file does not need to be named BUILD, but can be (something
like BUILD.new-repo-name may work well for distinguishing it
from the repository's actual BUILD files.
""",
        ),
        "bazel_toolchains_yocto_workspace_name": attr.string(
            doc = "The name given to the bazel-toolchains-yocto repository, if the default was not used.",
            default = "bazel_toolchains_yocto",
        ),
        "_post_script": attr.label(
            default = Label("//toolchains/private/scripts:post_extract.sh"),
            cfg = "exec",
            executable = True,
            allow_files = False,
        ),
    },
)

yocto_local_sdk = repository_rule(
    implementation = _yocto_local_sdk_impl,
    attrs = {
        "build_file": attr.label(
            allow_single_file = True,
            doc = """
The file to use as the BUILD file for the toolchain repository.
The file does not need to be named BUILD, but can be (something
like BUILD.new-repo-name may work well for distinguishing it
from the repository's actual BUILD files.
""",
        ),
        "bazel_toolchains_yocto_workspace_name": attr.string(
            doc = "The name given to the bazel-toolchains-yocto repository, if the default was not used.",
            default = "bazel_toolchains_yocto",
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
