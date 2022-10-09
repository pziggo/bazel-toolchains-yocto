filegroup(
    name = "target_sysroot_minimal",
    srcs = glob(
        [
            # Determine "#include <...>" search start
            # echo | {target_prefix}-gcc --sysroot={target_sysroot} -fno-canonical-system-headers -no-canonical-prefixes -E -Wp,-v -
            "{native_sysroot}/usr/lib/{target_prefix}/**",
            "{target_sysroot}/lib/*.so*",
            "{target_sysroot}/usr/include/**",
            "{target_sysroot}/usr/lib/**/*.a",
            "{target_sysroot}/usr/lib/**/*.o",
            "{target_sysroot}/usr/lib/**/*.so*",
        ],
    ),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "native_runtime",
    srcs = glob([
        "{native_sysroot}/lib/ld-*.so",
        "{native_sysroot}/lib/ld-linux*.so.*",
        "{native_sysroot}/lib/libc.so.*",
        "{native_sysroot}/lib/libdl.so.*",
        "{native_sysroot}/lib/libm.so.*",
        "{native_sysroot}/lib/libpthread.so.*",
        "{native_sysroot}/usr/lib/lib*.so.*",
        "{native_sysroot}/usr/libexec/{target_prefix}/**",
    ]),
)

filegroup(
    name = "gcc",
    srcs = [
        ":native_runtime",
        "{native_sysroot}/usr/bin/{target_prefix}/{target_prefix}-g++",
        "{native_sysroot}/usr/bin/{target_prefix}/{target_prefix}-gcc",
    ],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "cpp",
    srcs = [
        ":native_runtime",
        "{native_sysroot}/usr/bin/{target_prefix}/{target_prefix}-cpp",
    ],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "ar",
    srcs = [
        ":native_runtime",
        "{native_sysroot}/usr/bin/{target_prefix}/{target_prefix}-ar",
    ],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "ld",
    srcs = [
        ":native_runtime",
        "{native_sysroot}/usr/bin/{target_prefix}/{target_prefix}-ld",
    ],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "nm",
    srcs = [
        ":native_runtime",
        "{native_sysroot}/usr/bin/{target_prefix}/{target_prefix}-nm",
    ],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "objcopy",
    srcs = [
        ":native_runtime",
        "{native_sysroot}/usr/bin/{target_prefix}/{target_prefix}-objcopy",
    ],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "objdump",
    srcs = [
        ":native_runtime",
        "{native_sysroot}/usr/bin/{target_prefix}/{target_prefix}-objdump",
    ],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "strip",
    srcs = [
        ":native_runtime",
        "{native_sysroot}/usr/bin/{target_prefix}/{target_prefix}-strip",
    ],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "as",
    srcs = [
        ":native_runtime",
        "{native_sysroot}/usr/bin/{target_prefix}/{target_prefix}-as",
    ],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "addr2line",
    srcs = [
        ":native_runtime",
        "{native_sysroot}/usr/bin/{target_prefix}/{target_prefix}-addr2line",
    ],
    visibility = ["//visibility:public"],
)
