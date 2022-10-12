load("@{bazel_toolchains_yocto_workspace_name}//toolchains:cc_toolchain_config.bzl", "cc_toolchain_config")

filegroup(
    name = "ld-wrapper",
    srcs = ["ld-linux-x86-64.so.2"],
)

filegroup(
    name = "ar_files",
    srcs = [
        "//:ar",
        ":ld-wrapper",
        "{target_prefix}-ar",
    ],
)

filegroup(
    name = "as_files",
    srcs = [
        "//:as",
        ":ld-wrapper",
        "{target_prefix}-as",
    ],
)

filegroup(
    name = "compiler_files",
    srcs = [
        "//:as",
        "//:cpp",
        "//:gcc",
        "//:target_sysroot_minimal",
        ":ld-wrapper",
        "{target_prefix}-as",
        "{target_prefix}-cpp",
        "{target_prefix}-gcc",
        "as",
    ],
)

filegroup(
    name = "linker_files",
    srcs = [
        "//:ar",
        "//:gcc",
        "//:ld",
        "//:target_sysroot_minimal",
        ":ld-wrapper",
        "{target_prefix}-ar",
        "{target_prefix}-gcc",
        "{target_prefix}-ld",
        "real-ld",
    ],
)

filegroup(
    name = "objcopy_files",
    srcs = [
        "//:objcopy",
        ":ld-wrapper",
        "{target_prefix}-objcopy",
    ],
)

filegroup(
    name = "strip_files",
    srcs = [
        "//:strip",
        ":ld-wrapper",
        "{target_prefix}-strip",
    ],
)

filegroup(
    name = "all_files",
    srcs = [
        ":ar_files",
        ":as_files",
        ":compiler_files",
        ":linker_files",
        ":objcopy_files",
        ":strip_files",
    ],
)

filegroup(
    name = "empty",
    srcs = [],
)

cc_toolchain_config(
    name = "cc-toolchain-config",
    cpu = "{target_arch}",
    compiler = "gcc",
    toolchain_identifier = "{name}",
    host_system_name = "{native_prefix}",
    target_system_name = "{target_prefix}",
    target_libc = "unknown",
    abi_version = "unknown",
    abi_libc_version = "unknown",
    cxx_builtin_include_directories = {cxx_builtin_include_directories},
    tool_paths = {tool_paths},
    compile_flags = {compile_flags},
    dbg_compile_flags = {dbg_compile_flags},
    opt_compile_flags = {opt_compile_flags},
    cxx_flags = {cxx_flags},
    link_flags = {link_flags},
    archive_flags = {archive_flags},
    link_libs = {link_libs},
    opt_link_flags = {opt_link_flags},
    builtin_sysroot = "{builtin_sysroot}",
)

cc_toolchain(
    name = "cc-target",
    all_files = ":all_files",
    ar_files = ":ar_files",
    as_files = ":as_files",
    compiler_files = ":compiler_files",
    dwp_files = ":empty",
    linker_files = ":linker_files",
    objcopy_files = ":objcopy_files",
    strip_files = ":strip_files",
    supports_param_files = 1,
    toolchain_config = "cc-toolchain-config",
)

toolchain(
    name = "cc-toolchain-target",
    exec_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
    ],
    target_compatible_with = [
        "@platforms//cpu:{target_arch}",
        "@platforms//os:{target_os}",
    ],
    toolchain = ":cc-target",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)
