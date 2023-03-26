""" Extract a Yocto SDK installer """

load("@bazel_skylib//lib:paths.bzl", "paths")
load(
    "//yocto/private:common_utils.bzl",
    "env_pair",
    "env_to_config",
)
load(
    "//yocto/private:build_templates.bzl",
    "BUILD_for_platform",
    "BUILD_for_sdk_tree",
)
load("//yocto/private:toolchain_template.bzl", "BUILD_for_toolchain")
load(
    "//yocto/private:wrapper_templates.bzl",
    "WRAPPER_for_compiler",
    "WRAPPER_for_generic_tool",
    "WRAPPER_for_ld",
    "WRAPPER_for_real_ld",
)

def _setup_bazel_files(repository_ctx, config):
    repository_ctx.file("WORKSPACE.bazel", """workspace(name = "{}")""".format(
        repository_ctx.name,
    ))

    path = "external/{}".format(repository_ctx.attr.name)

    if repository_ctx.attr.build_file:
        repository_ctx.file("BUILD.bazel", repository_ctx.read(repository_ctx.attr.build_file))
    elif repository_ctx.attr.build_file_content:
        repository_ctx.file("BUILD.bazel", repository_ctx.attr.build_file_content)
    else:
        repository_ctx.file(
            "BUILD.bazel",
            content = BUILD_for_sdk_tree(config),
            executable = False,
        )

    repository_ctx.file(
        "bazel/BUILD.bazel",
        content = BUILD_for_platform(config),
        executable = False,
    )

    repository_ctx.file(
        "bazel/toolchain/ld-linux-x86-64.so.2",
        content = WRAPPER_for_ld(path, config),
        executable = True,
    )

    for tool in ["cpp", "gcc"]:
        repository_ctx.file(
            "bazel/toolchain/{}-{}".format(config.target_prefix, tool),
            content = WRAPPER_for_compiler(
                "{}-{}".format(config.target_prefix, tool),
                path,
                config,
            ),
            executable = True,
        )

    for tool in ["ar", "as", "ld", "nm", "objcopy", "objdump", "strip"]:
        repository_ctx.file(
            "bazel/toolchain/{}-{}".format(config.target_prefix, tool),
            content = WRAPPER_for_generic_tool(
                "{}-{}".format(config.target_prefix, tool),
                path,
                config,
            ),
            executable = True,
        )

    repository_ctx.file(
        "bazel/toolchain/as",
        content = WRAPPER_for_generic_tool(
            "{}-as".format(config.target_prefix),
            path,
            config,
        ),
        executable = True,
    )

    # 'real-ld' in the exec path takes precedence over std paths.
    # Create a `real-ld` wrapper to ensure the correct ld is called.
    # https://gcc.gnu.org/onlinedocs/gccint/Collect2.html#Collect2
    repository_ctx.file(
        "bazel/toolchain/real-ld",
        content = WRAPPER_for_real_ld(path, config),
        executable = True,
    )

    repository_ctx.file(
        "bazel/toolchain/BUILD.bazel",
        content = BUILD_for_toolchain(repository_ctx.attr.name, config),
        executable = False,
    )

def _read_env_from_environment_setup(repository_ctx):
    env = dict()

    environment_setup = repository_ctx.read("{}".format(repository_ctx.attr.environment_setup))

    environment_setup_lines = environment_setup.splitlines()

    export_prefix = "export "
    for line in environment_setup_lines:
        if line.startswith(export_prefix):
            env.update(env_pair(line.removeprefix(export_prefix)))

    return env

def _install_sdk(repository_ctx):
    repository_ctx.report_progress("Installing Yocto SDK {}".format(repository_ctx.path(repository_ctx.attr.sdk_installer)))
    res = repository_ctx.execute(["sh", repository_ctx.path(repository_ctx.attr.sdk_installer), "-y", "-d", repository_ctx.path("."), "-R"])
    if res.return_code:
        fail("error installing Yocto SDK:\n" + res.stdout + res.stderr)

def _fix_ld_scripts(repository_ctx, config):
    """Fix the yocto ld scripts

    Yocto omits the sysroot prefix in the ld scripts within the toolchain. In
    case or cross-compilation, this ignores the given sysroot paths and thus
    the linker tries to link against the absolut path which is pointing to the
    host libraries.
    """
    for linker_script in ["/usr/lib/libc.so", "/usr/lib/libm.so", "/usr/lib/libpthread.so"]:
        res = repository_ctx.execute([repository_ctx.path(repository_ctx.attr._post_script), config.target_sysroot, linker_script])
        if res.return_code == 0 and res.stdout:
            repository_ctx.file("bazel/toolchain/{}".format(paths.basename(linker_script)), content = res.stdout)
        elif res.return_code != 0:
            fail("error post patching Yocto SDK: \n" + res.stdout + res.stderr)

def _link_sdk(repository_ctx):
    native_sysroot = repository_ctx.os.environ.get("OECORE_NATIVE_SYSROOT")
    target_sysroot = repository_ctx.os.environ.get("SDKTARGETSYSROOT")

    native_sysroot_link = repository_ctx.path(native_sysroot).basename
    target_sysroot_link = repository_ctx.path(target_sysroot).basename

    repository_ctx.symlink(native_sysroot, native_sysroot_link)
    repository_ctx.symlink(target_sysroot, target_sysroot_link)

def _install_and_setup_sdk_impl(repository_ctx):
    if repository_ctx.attr.build_file and repository_ctx.attr.build_file_content:
        fail("Only one of build_file and build_file_content can be provided.")

    _install_sdk(repository_ctx)

    env = _read_env_from_environment_setup(repository_ctx)
    config = env_to_config(repository_ctx, env)
    _fix_ld_scripts(repository_ctx, config)
    _setup_bazel_files(repository_ctx, config)

install_and_setup_sdk = repository_rule(
    implementation = _install_and_setup_sdk_impl,
    attrs = {
        "build_file": attr.label(
            allow_single_file = True,
            mandatory = False,
            doc =
                "The file to use as the BUILD file for the SDK tree. " +
                "This attribute is an absolute label (use '@//' for the main " +
                "repo). The file does not need to be named BUILD, but can " +
                "be (something like BUILD.new-repo-name may work well for " +
                "distinguishing it from the repository's actual BUILD files. " +
                "Either build_file or build_file_content can be specified, but " +
                "not both.",
        ),
        "build_file_content": attr.string(
            mandatory = False,
            doc =
                "The content for the BUILD file for the SDK tree. " +
                "Either build_file or build_file_content can be specified, but " +
                "not both.",
        ),
        "environment_setup": attr.string(
            mandatory = True,
            doc = "",
        ),
        "sdk_installer": attr.label(
            mandatory = True,
            allow_single_file = True,
            doc = "",
        ),
        "_post_script": attr.label(
            default = Label("//scripts:post_extract.sh"),
            cfg = "exec",
            executable = True,
            allow_files = False,
        ),
    },
)

def _link_and_setup_sdk_impl(repository_ctx):
    if repository_ctx.attr.build_file and repository_ctx.attr.build_file_content:
        fail("Only one of build_file and build_file_content can be provided.")

    _link_sdk(repository_ctx)
    config = env_to_config(repository_ctx, repository_ctx.os.environ)
    _fix_ld_scripts(repository_ctx, config)
    _setup_bazel_files(repository_ctx, config)

link_and_setup_sdk = repository_rule(
    implementation = _link_and_setup_sdk_impl,
    attrs = {
        "build_file": attr.label(
            allow_single_file = True,
            mandatory = False,
            doc =
                "The file to use as the BUILD file for the SDK tree. " +
                "This attribute is an absolute label (use '@//' for the main " +
                "repo). The file does not need to be named BUILD, but can " +
                "be (something like BUILD.new-repo-name may work well for " +
                "distinguishing it from the repository's actual BUILD files. " +
                "Either build_file or build_file_content can be specified, but " +
                "not both.",
        ),
        "build_file_content": attr.string(
            mandatory = False,
            doc =
                "The content for the BUILD file for the SDK tree. " +
                "Either build_file or build_file_content can be specified, but " +
                "not both.",
        ),
        "_post_script": attr.label(
            default = Label("//scripts:post_extract.sh"),
            cfg = "exec",
            executable = True,
            allow_files = False,
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
        "UNINATIVE_LOADER",
    ],
)
