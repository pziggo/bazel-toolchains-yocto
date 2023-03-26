"""Utility macros for use in repository rules"""

load("@bazel_skylib//lib:paths.bzl", "paths")

def format_command_options(options, strip_command = False):
    """Convert command options from string to list

    Args:
        options (str): Command line options
        strip_command (bool, opional): Wether to strip the first element supposed to be the command or not

    Returns:
        List: The resulting command options
    """
    elements = []
    for element in options.split(" "):
        if element.strip("\""):
            elements.append(element.strip("\""))

    if strip_command:
        elements.pop(0)

    return elements

def relativize_sysroot_path(
        repository_name,
        repository_path,
        sysroot):
    """Convert absolut sysroot path from env to relative path in outputBase

    Args:
        repository_name (str): Name of the external repository
        repository_path (str): Absolut path to external repository
        sysroot (str): Origin absolut sysroot path

    Returns:
        Str: The relative path in outputBase
    """
    relative_path = ""
    skip_anchor = 0

    repository_segments = paths.normalize(repository_path).split("/")
    sysroot_segments = paths.normalize(sysroot).split("/")

    sysroot_length = len(sysroot_segments)
    anchor = repository_segments[-1]

    if repository_name == anchor:
        skip_anchor = 1

    for i in range(sysroot_length):
        if sysroot_segments[i] == anchor:
            relative_path = "/".join(sysroot_segments[-(sysroot_length - i - skip_anchor):])

    if not len(relative_path):
        # No common anchor, assume sysroot is external and linked into workspace
        relative_path = sysroot_segments[-1]

    return relative_path

def remove_elements_starting_with_keyword(keyword, my_list):
    return [element for element in my_list if not element.startswith(keyword)]

def env_pair(line):
    k, _, v = line.partition("=")
    return {k: v.strip("\"")}

def env_to_config(repository_ctx, env, relative_root = "."):
    """Convert SDK configuration from environment dict into a config structure.

    Args:
        repository_ctx (repository_ctx): The rule's context object.
        env (dict): Environment variables to read toolchain config from.
        relative_root (str, optional): Root for relative paths

    Returns:
        struct: The toolchain configuration
    """

    repo_root = str(repository_ctx.path(relative_root))

    archive_flags = []

    compile_flags = format_command_options(env.get("CC"), True)
    cxx_builtin_include_directories = []
    dbg_compile_flags = []
    link_flags = format_command_options(env.get("LD"), True)
    link_libs = ["-lstdc++", "-lm"]
    native_prefix = paths.basename(env.get("OECORE_NATIVE_SYSROOT"))
    native_sysroot = relativize_sysroot_path(
        repository_ctx.name,
        repo_root,
        env.get("OECORE_NATIVE_SYSROOT"),
    )
    opt_compile_flags = []
    opt_link_flags = []
    target_arch = env.get("OECORE_TARGET_ARCH")
    target_os = env.get("OECORE_TARGET_OS")
    target_prefix = env.get("TARGET_PREFIX").removesuffix("-")
    target_sysroot = relativize_sysroot_path(
        repository_ctx.name,
        repo_root,
        env.get("SDKTARGETSYSROOT"),
    )
    unfiltered_compile_flags = [
        "-no-canonical-prefixes",
        "-fno-canonical-system-headers",
        "-Wno-builtin-macro-redefined",
    ]

    builtin_sysroot = "external/{}/{}".format(
        repository_ctx.attr.name,
        target_sysroot,
    )

    compile_flags.extend(format_command_options(env.get("CFLAGS")))
    link_flags.extend(format_command_options(env.get("LDFLAGS")))

    # only add flags if not in compile_flags
    cxx_flags = [flag for flag in format_command_options(env.get("CXX"), True) if flag not in compile_flags]
    cxx_flags.extend([flag for flag in format_command_options(env.get("CXXFLAGS")) if flag not in compile_flags])

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

    # sysroot will be added by bazel toolchain config via builtin_sysroot variable
    compile_flags = remove_elements_starting_with_keyword("--sysroot", compile_flags)
    link_flags = remove_elements_starting_with_keyword("--sysroot", link_flags)

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
