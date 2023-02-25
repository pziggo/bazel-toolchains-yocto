"""Utility macros for use in repository rules"""

load("@bazel_skylib//lib:paths.bzl", "paths")

def _format_flags(iterable):
    """Format flags and remove empty elements."""
    return _unique([element for element in iterable if element])

def _replace_in_flags(iterable, old, new):
    """Replace string in all occurences of the given flags."""
    elements = []
    for element in iterable:
        elements.append(element.replace(old, new))
    return elements

def _unique(iterable):
    """Remove duplicates from a list."""
    elements = []
    for element in iterable:
        if element not in elements:
            elements.append(element)
    return elements

def env_pair(line):
    k, _, v = line.partition("=")
    return {k: v.strip("\"").split(" ")}

def env_to_config(repository_ctx, env):
    """Convert SDK configuration from environment dict into a config structure.

    Args:
        repository_ctx (repository_ctx): The rule's context object.
        env (dict): Environment variables to read toolchain config from.

    Returns:
        struct: The toolchain configuration
    """
    repo_root = str(repository_ctx.path("."))

    archive_flags = []
    builtin_sysroot = ""
    compile_flags = _format_flags(env.get("CC")[1:])
    cxx_builtin_include_directories = []
    dbg_compile_flags = []
    link_flags = _format_flags(env.get("LD")[1:])
    link_libs = ["-lstdc++", "-lm"]
    native_prefix = paths.basename(env.get("OECORE_NATIVE_SYSROOT")[0])
    native_sysroot = paths.relativize(env.get("OECORE_NATIVE_SYSROOT")[0], repo_root)
    opt_compile_flags = []
    opt_link_flags = []
    target_arch = env.get("OECORE_TARGET_ARCH")[0]
    target_os = env.get("OECORE_TARGET_OS")[0]
    target_prefix = env.get("TARGET_PREFIX")[0].removesuffix("-")
    target_sysroot = paths.relativize(env.get("SDKTARGETSYSROOT")[0], repo_root)
    unfiltered_compile_flags = [
        "-no-canonical-prefixes",
        "-fno-canonical-system-headers",
        "-Wno-builtin-macro-redefined",
    ]

    compile_flags.extend(_format_flags(env.get("CFLAGS")))
    link_flags.extend(_format_flags(env.get("LDFLAGS")))

    # only add flags if not in compile_flags
    cxx_flags = [flag for flag in _format_flags(env.get("CXX")[1:]) if flag not in compile_flags]
    cxx_flags.extend([flag for flag in _format_flags(env.get("CXXFLAGS")) if flag not in compile_flags])

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
        "llvm-cov": "/bin/false",
        "nm": "{}-nm".format(target_prefix),
        "objcopy": "{}-objcopy".format(target_prefix),
        "objdump": "{}-objdump".format(target_prefix),
        "strip": "{}-strip".format(target_prefix),
    }

    compile_flags = _replace_in_flags(
        compile_flags,
        "$SDKTARGETSYSROOT",
        "external/{}/{}".format(
            repository_ctx.attr.name,
            target_sysroot,
        ),
    )
    link_flags = _replace_in_flags(
        link_flags,
        "$SDKTARGETSYSROOT",
        "external/{}/{}".format(
            repository_ctx.attr.name,
            target_sysroot,
        ),
    )

    return struct(
        archive_flags = archive_flags,
        builtin_sysroot = builtin_sysroot,
        compile_flags = compile_flags,
        cxx_builtin_include_directories = cxx_builtin_include_directories,
        cxx_flags = cxx_flags,
        dbg_compile_flags = dbg_compile_flags,
        link_flags = link_flags,
        link_libs = link_libs,
        native_prefix = native_prefix,
        native_sysroot = native_sysroot,
        opt_compile_flags = opt_compile_flags,
        opt_link_flags = opt_link_flags,
        target_arch = target_arch,
        target_os = target_os,
        target_prefix = target_prefix,
        target_sysroot = target_sysroot,
        tool_paths = tool_paths,
        unfiltered_compile_flags = unfiltered_compile_flags,
    )
