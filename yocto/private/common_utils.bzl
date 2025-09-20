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
    oecore_native_sysroot = env.get("OECORE_NATIVE_SYSROOT")

    compile_flags = format_command_options(env.get("CC"), True)
    compile_flags_clang = format_command_options(env.get("CLANGCC"), True)
    # ToDo - improve to not use hardcoded versions here
    cxx_builtin_include_directories = [oecore_native_sysroot + "/usr/lib/gcc/x86_64-linux-gnu/13.3.0/include", oecore_native_sysroot + "/usr/include"]
    cxx_builtin_include_directories_clang = [oecore_native_sysroot + "/usr/lib/clang/20/include/", oecore_native_sysroot + "/usr/include"]
    dbg_compile_flags = []
    dynamic_linker = env.get("UNINATIVE_LOADER")
    link_flags = format_command_options(env.get("LD"), True)
    link_flags_clang = ["-fuse-ld=lld"] + compile_flags_clang + link_flags
    link_libs = ["-lstdc++", "-lm"]
    native_prefix = paths.basename(oecore_native_sysroot)
    native_sysroot = relativize_sysroot_path(
        repository_ctx.name,
        repo_root,
        oecore_native_sysroot,
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

    # Get absolute paths for include directory resolution (after basic variables are defined)
    native_sysroot_abs = paths.join(repo_root, native_sysroot)
    target_sysroot_abs = paths.join(repo_root, target_sysroot)
    native_sysroot_real = env.get("OECORE_NATIVE_SYSROOT")
    unfiltered_compile_flags = [
        "-no-canonical-prefixes",
        "-fno-canonical-system-headers",
        "-Wno-builtin-macro-redefined",
    ]
    unfiltered_compile_flags_clang = [
        "-no-canonical-prefixes",
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
    cxx_flags_clang = [flag for flag in format_command_options(env.get("CLANGCXX"), True) if flag not in compile_flags]
    cxx_flags_clang.extend([flag for flag in format_command_options(env.get("CXXFLAGS")) if flag not in compile_flags])

    # Detect the C++/GCC version by examining the target sysroot
    cpp_ver_dir = paths.join(target_sysroot_abs, "usr/include/c++")
    res = repository_ctx.execute(["bash", "-c", "ls -1 " + cpp_ver_dir + " 2>/dev/null | head -n1"], quiet = True)
    gcc_ver = res.stdout.strip() if res.return_code == 0 and res.stdout.strip() else "13.3.0"

    # Add C++ and GCC builtin include directories to whitelist
    cxx_builtin_include_directories.extend([
        # Target sysroot include directories
        paths.join(target_sysroot_abs, "usr/include"),
        paths.join(target_sysroot_abs, "usr/include/c++", gcc_ver),
        paths.join(target_sysroot_abs, "usr/include/{tp}/c++".format(tp = target_prefix), gcc_ver),
        paths.join(target_sysroot_abs, "usr/include/c++", gcc_ver, target_prefix),
        # GCC builtin headers in native sysroot (where GCC toolchain is located)
        paths.join(native_sysroot_real, "usr/lib/{tp}/gcc/{tp}".format(tp = target_prefix), gcc_ver, "include"),
        paths.join(native_sysroot_real, "usr/lib/{tp}/gcc/{tp}".format(tp = target_prefix), gcc_ver, "include-fixed"),
        # Also add the /proc/self/cwd/ prefixed versions that the compiler reports
        "/proc/self/cwd/" + paths.join(native_sysroot, "usr/lib/{tp}/gcc/{tp}".format(tp = target_prefix), gcc_ver, "include"),
        "/proc/self/cwd/" + paths.join(native_sysroot, "usr/lib/{tp}/gcc/{tp}".format(tp = target_prefix), gcc_ver, "include-fixed"),
        "/proc/self/cwd/" + paths.join(target_sysroot, "usr/include"),
        "/proc/self/cwd/" + paths.join(target_sysroot, "usr/include/c++", gcc_ver),
        "/proc/self/cwd/" + paths.join(target_sysroot, "usr/include/c++", gcc_ver, target_prefix),
        # Add the full external repository prefixed versions as reported by compiler
        "/proc/self/cwd/external/" + repository_ctx.name + "/" + paths.join(native_sysroot, "usr/lib/{tp}/gcc/{tp}".format(tp = target_prefix), gcc_ver, "include"),
        "/proc/self/cwd/external/" + repository_ctx.name + "/" + paths.join(native_sysroot, "usr/lib/{tp}/gcc/{tp}".format(tp = target_prefix), gcc_ver, "include-fixed"),
        "/proc/self/cwd/external/" + repository_ctx.name + "/" + paths.join(target_sysroot, "usr/include"),
        "/proc/self/cwd/external/" + repository_ctx.name + "/" + paths.join(target_sysroot, "usr/include/c++", gcc_ver),
        "/proc/self/cwd/external/" + repository_ctx.name + "/" + paths.join(target_sysroot, "usr/include/c++", gcc_ver, target_prefix),
    ])

    # Add clang builtin include directories
    cxx_builtin_include_directories_clang.extend([
        # Target sysroot include directories
        paths.join(target_sysroot_abs, "usr/include"),
        paths.join(target_sysroot_abs, "usr/include/c++", gcc_ver),
        paths.join(target_sysroot_abs, "usr/include/{tp}/c++".format(tp = target_prefix), gcc_ver),
        paths.join(target_sysroot_abs, "usr/include/c++", gcc_ver, target_prefix),
        # Clang builtin headers in native sysroot
        paths.join(native_sysroot_real, "usr/lib/clang/20/include"),
        # GCC builtin headers that clang may also need
        paths.join(native_sysroot_real, "usr/lib/{tp}/gcc/{tp}".format(tp = target_prefix), gcc_ver, "include"),
        paths.join(native_sysroot_real, "usr/lib/{tp}/gcc/{tp}".format(tp = target_prefix), gcc_ver, "include-fixed"),
        # Also add the /proc/self/cwd/ prefixed versions that the compiler reports
        "/proc/self/cwd/" + paths.join(native_sysroot, "usr/lib/clang/20/include"),
        "/proc/self/cwd/" + paths.join(native_sysroot, "usr/lib/{tp}/gcc/{tp}".format(tp = target_prefix), gcc_ver, "include"),
        "/proc/self/cwd/" + paths.join(native_sysroot, "usr/lib/{tp}/gcc/{tp}".format(tp = target_prefix), gcc_ver, "include-fixed"),
        "/proc/self/cwd/" + paths.join(target_sysroot, "usr/include"),
        "/proc/self/cwd/" + paths.join(target_sysroot, "usr/include/c++", gcc_ver),
        "/proc/self/cwd/" + paths.join(target_sysroot, "usr/include/c++", gcc_ver, target_prefix),
        # Add the full external repository prefixed versions as reported by compiler
        "/proc/self/cwd/external/" + repository_ctx.name + "/" + paths.join(native_sysroot, "usr/lib/clang/20/include"),
        "/proc/self/cwd/external/" + repository_ctx.name + "/" + paths.join(native_sysroot, "usr/lib/{tp}/gcc/{tp}".format(tp = target_prefix), gcc_ver, "include"),
        "/proc/self/cwd/external/" + repository_ctx.name + "/" + paths.join(native_sysroot, "usr/lib/{tp}/gcc/{tp}".format(tp = target_prefix), gcc_ver, "include-fixed"),
        "/proc/self/cwd/external/" + repository_ctx.name + "/" + paths.join(target_sysroot, "usr/include"),
        "/proc/self/cwd/external/" + repository_ctx.name + "/" + paths.join(target_sysroot, "usr/include/c++", gcc_ver),
        "/proc/self/cwd/external/" + repository_ctx.name + "/" + paths.join(target_sysroot, "usr/include/c++", gcc_ver, target_prefix),
    ])

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

    tool_paths_clang = {
        "addr2line": "/bin/false",
        "ar": "{}-ar".format(target_prefix),
        "as": "{}-as".format(target_prefix),
        "compat-ld": "/bin/false",
        "cpp": "{}-cpp".format(target_prefix),
        "dwp": "/bin/false",
        "gcc": "{}-clang".format(target_prefix),
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
    compile_flags_clang = remove_elements_starting_with_keyword("--sysroot", compile_flags_clang)
    
    # Add canonical repository include paths for spawn_strategy=local
    # Use -nostdinc++ to disable compiler built-in search paths that look in wrong locations
    canonical_include_paths = [
        "-nostdinc++",  # Disable built-in C++ include paths to prevent /include/c++ searches
        "-I" + "external/+yocto_ext+yocto_aarch64/" + target_sysroot + "/usr/include",
        "-I" + "external/+yocto_ext+yocto_aarch64/" + target_sysroot + "/usr/include/c++/13.3.0",
        "-I" + "external/+yocto_ext+yocto_aarch64/" + target_sysroot + "/usr/include/c++/13.3.0/" + target_prefix,
    ]
    compile_flags.extend(canonical_include_paths)
    compile_flags_clang.extend(canonical_include_paths)
    link_flags = remove_elements_starting_with_keyword("--sysroot", link_flags)
    link_flags_clang = remove_elements_starting_with_keyword("--sysroot", link_flags_clang)

    # Check for rules_foreign_cc build tools in the SDK
    # HARDCODED: Always enable foreign_cc toolchain
    enable_foreign_cc = True
    cmake_available = True
    ninja_available = True
    pkg_config_available = True
    make_available = True

    if native_sysroot_real:
        # Check for cmake
        cmake_res = repository_ctx.execute(["test", "-f", native_sysroot_real + "/usr/bin/cmake"], quiet = True)
        cmake_available = cmake_res.return_code == 0

        # Check for ninja
        ninja_res = repository_ctx.execute(["test", "-f", native_sysroot_real + "/usr/bin/ninja"], quiet = True)
        ninja_available = ninja_res.return_code == 0

        # Check for pkg-config
        pkg_config_res = repository_ctx.execute(["test", "-f", native_sysroot_real + "/usr/bin/pkg-config"], quiet = True)
        pkg_config_available = pkg_config_res.return_code == 0

        # Check for make (various names)
        make_res = repository_ctx.execute(["sh", "-c", "test -f " + native_sysroot_real + "/usr/bin/make || test -f " + native_sysroot_real + "/usr/bin/gmake"], quiet = True)
        make_available = make_res.return_code == 0


    return struct(
        builtin_sysroot = builtin_sysroot,
        compile_flags = compile_flags,
        compile_flags_clang = compile_flags_clang,
        cxx_builtin_include_directories = cxx_builtin_include_directories,
        cxx_builtin_include_directories_clang = cxx_builtin_include_directories_clang,
        cxx_flags = cxx_flags,
        cxx_flags_clang = cxx_flags_clang,
        dbg_compile_flags = dbg_compile_flags,
        dynamic_linker = dynamic_linker,
        enable_foreign_cc = enable_foreign_cc,
        link_flags = link_flags,
        link_flags_clang = link_flags_clang,
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
        tool_paths_clang = tool_paths_clang,
        unfiltered_compile_flags = unfiltered_compile_flags,
        unfiltered_compile_flags_clang = unfiltered_compile_flags_clang,
    )
